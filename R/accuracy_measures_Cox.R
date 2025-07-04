tvROC.coxph <-
    function (object, newdata, Tstart, Thoriz = NULL, Dt = NULL,
              type_weights = c("model-based", "IPCW"), ...) {
    if (!inherits(object, "coxph"))
        stop("Use only with 'coxph' objects.\n")
    if (!is.data.frame(newdata) || nrow(newdata) == 0)
        stop("'newdata' must be a data.frame with more than one rows.\n")
    if (is.null(Thoriz) && is.null(Dt))
        stop("either 'Thoriz' or 'Dt' must be non null.\n")
    if (!is.null(Thoriz) && Thoriz <= Tstart)
        stop("'Thoriz' must be larger than 'Tstart'.")
    if (is.null(Thoriz))
        Thoriz <- Tstart + Dt
    type_censoring <- attr(object$y, "type")
    if (type_censoring != "right")
        stop("'tvROC()' currently only works for right censored data.")
    type_weights <- match.arg(type_weights)
    Tstart <- Tstart + 1e-06
    Thoriz <- Thoriz + 1e-06
    mframe <- model.frame(object$terms, data = newdata)
    Y <- model.response(mframe)
    Time <- Y[, 'time']
    newdata <- newdata[Time >= Tstart, ]
    mframe <- model.frame(object$terms, data = newdata)
    Y <- model.response(mframe)
    Time <- Y[, 'time']
    event <- Y[, 'status']
    sfit0 <- summary(survfit(object, newdata = newdata), times = Tstart)
    sfit <- summary(survfit(object, newdata = newdata), times = Thoriz)
    qi_u_t <- as.matrix(sfit$surv)[1L, ] / as.matrix(sfit0$surv)[1L, ]
    thrs <- seq(0, 1, length = 101)
    Check <- outer(qi_u_t, thrs, "<")
    if (type_weights == "model-based") {
        # subjects who died before Thoriz
        ind1 <- Time < Thoriz & event == 1
        # subjects who were censored in the interval (Tstart, Thoriz)
        ind2 <- Time < Thoriz & event == 0
        ind <- ind1 | ind2
        if (any(ind2)) {
            sfit02 <- summary(survfit(object, newdata = newdata[ind2, ]),
                             times = Tstart)
            sfit2 <- summary(survfit(object, newdata = newdata[ind2, ]),
                             times = Thoriz)
            pi_u_t <- 1.0 - (as.matrix(sfit2$surv)[1L, ] / as.matrix(sfit02$surv)[1L, ])
            nams <- names(ind2[ind2])
            ind[nams] <- ind[nams] * pi_u_t[nams]
        }
        # calculate sensitivity and specificity
        nTP <- colSums(Check * c(ind))
        nFN <- sum(ind) - nTP
        TP <- nTP / sum(ind)
        nFP <- colSums(Check * c(1 - ind))
        nTN <- sum(1 - ind) - nFP
        FP <- nFP / sum(1 - ind)
    } else {
        ind1 <- Time < Thoriz & event == 1
        ind2 <- Time > Thoriz
        nFP <- colSums(Check * c(ind2))
        nTN <- sum(ind2) - nFP
        FP <- nFP / sum(ind2)
        cens_data <- data.frame(Time = Time, cens_ind = 1 - event)
        censoring_dist <- survfit(Surv(Time, cens_ind) ~ 1, data = cens_data)
        weights <- numeric(length(Time))
        ss <- summary(censoring_dist, times = Time[ind1])
        weights[ind1] <- 1 / ss$surv[match(ss$time, Time[ind1])]
        nTP <- colSums(Check[ind1, , drop = FALSE] / weights[ind1])
        nFN <- sum(1 / weights[ind1]) - nTP
        TP <- nTP / sum(1 / weights[ind1])
    }
    f1score <- 2 * nTP / (2 * nTP + nFN + nFP)
    F1score <- median(thrs[f1score == max(f1score)])
    youden <- TP - FP
    Youden <- median(thrs[youden == max(youden)])
    out <- list(TP = TP, FP = FP, nTP = nTP, nFN = nFN, nFP = nFP, nTN = nTN,
                thrs = thrs, F1score = F1score, Youden = Youden,
                Tstart = Tstart, Thoriz = Thoriz, nr = nrow(newdata),
                classObject = class(object), type_weights = type_weights,
                nameObject = deparse(substitute(object)))
    class(out) <- "tvROC"
    out
}

tvAUC.coxph <- function (object, newdata, Tstart, Thoriz = NULL, Dt = NULL,
                         type_weights = c("model-based", "IPCW"), ...) {
    roc <- tvROC(object, newdata, Tstart, Thoriz, Dt, type_weights, ...)
    TP <- roc$TP
    FP <- roc$FP
    auc <- sum(0.5 * diff(FP) * (TP[-1L] + TP[-length(TP)]), na.rm = TRUE)
    out <- list(auc = auc,
                Tstart = Tstart, Thoriz = roc$Thoriz, nr = roc$nr,
                type_weights = roc$type_weights,
                classObject = class(object),
                nameObject = deparse(substitute(object)))
    class(out) <- "tvAUC"
    out
}


tvBrier.coxph <- function (object, newdata, Tstart, Thoriz = NULL, Dt = NULL,
                           integrated = FALSE,
                           type_weights = c("model-based", "IPCW"), ...) {
    if (!inherits(object, "coxph"))
        stop("Use only with 'coxph' objects.\n")
    if (!is.data.frame(newdata) || nrow(newdata) == 0)
        stop("'newdata' must be a data.frame with more than one rows.\n")
    if (is.null(Thoriz) && is.null(Dt))
        stop("either 'Thoriz' or 'Dt' must be non null.\n")
    if (!is.null(Thoriz) && Thoriz <= Tstart)
        stop("'Thoriz' must be larger than 'Tstart'.")
    if (is.null(Thoriz))
        Thoriz <- Tstart + Dt
    type_censoring <- attr(object$y, "type")
    if (type_censoring != "right")
        stop("'tvROC()' currently only works for right censored data.")
    type_weights <- match.arg(type_weights)
    Tstart <- Tstart + 1e-06
    Thoriz <- Thoriz + 1e-06
    mframe <- model.frame(object$terms, data = newdata)
    Y <- model.response(mframe)
    Time <- Y[, 'time']
    newdata <- newdata[Time >= Tstart, ]
    mframe <- model.frame(object$terms, data = newdata)
    Y <- model.response(mframe)
    Time <- Y[, 'time']
    event <- Y[, 'status']
    brier_fun <- function (pi_u_t, type_weights, weights, ind1, ind2, ind3) {
        loss <- function (x) x * x
        res <- if (type_weights == "model-based") {
            events <- sum(loss(1.0 - pi_u_t[ind1]), na.rm = TRUE)
            no_events <- sum(loss(pi_u_t[ind2]), na.rm = TRUE)
            censored <- if (any(ind3)) {
                sum(weights * loss(1.0 - pi_u_t[ind3]) +
                        (1.0 - weights) * loss(pi_u_t[ind3]), na.rm = TRUE)
            } else 0.0
            (events + no_events + censored) / length(ind1)
        } else {
            mean(loss(as.numeric(ind1) - pi_u_t) * weights)
        }
        res
    }
    ############################################################################
    br <- function (Thoriz) {
        sfit0 <- summary(survfit(object, newdata = newdata), times = Tstart)
        sfit <- summary(survfit(object, newdata = newdata), times = Thoriz)
        pi_u_t <- 1.0 - (as.matrix(sfit$surv)[1L, ] / as.matrix(sfit0$surv)[1L, ])
        # subjects who had the event before Thoriz
        ind1 <- Time < Thoriz & event == 1
        # subjects who had the event after Thoriz
        ind2 <- Time > Thoriz
        # subjects who were censored in the interval (Tstart, Thoriz)
        ind3 <- Time < Thoriz & event == 0
        if (sum(ind1) < 5) {
            warning("there are fewer than 5 subjects with an event in the interval [",
                    Tstart, ", ", Thoriz, ").\n")
        }
        if (type_weights == "IPCW") {
            cens_data <- data.frame(Time = Time, cens_ind = 1 - event)
            censoring_dist <- survfit(Surv(Time, cens_ind) ~ 1, data = cens_data)
            weights <- numeric(length(Time))
            ss <- summary(censoring_dist, times = Time[ind1])
            weights[ind1] <- 1.0 / ss$surv[match(ss$time, Time[ind1])]
            weights[ind2] <- 1.0 / summary(censoring_dist, times = Thoriz)$surv
        } else {
            weights <- if (any(ind3)) {
                sfit2 <- summary(survfit(object, newdata = newdata[ind3, ]),
                                 times = Thoriz)
                1.0 - as.matrix(sfit2$surv)[1L, ]
            }
        }
        brier_fun(pi_u_t, type_weights, weights, ind1, ind2, ind3)
    }
    Brier <- if (integrated) {
        br1 <- br(0.5 * (Tstart + Thoriz))
        br2 <- br(Thoriz)
        2 * br1 / 3 + br2 / 6
    } else {
        br(Thoriz)
    }
    out <- list(Brier = Brier,
                nr = length(Time), nint = sum(Time < Thoriz & event),
                ncens = sum(Time < Thoriz & event == 0),
                Tstart = Tstart, Thoriz = Thoriz,
                integrated = integrated, type_weights = type_weights,
                classObject = class(object),
                nameObject = deparse(substitute(object)))
    class(out) <- "tvBrier"
    out
}

calibration_plot.coxph <-
    function (object, newdata, Tstart, Thoriz = NULL,
              Dt = NULL, df_ns = NULL, plot = TRUE,
              col = "red", lty = 1, lwd = 1,
              add_CI = TRUE, col_CI = "lightgrey",
              add_density = TRUE, col_dens = "grey",
              xlab = "Predicted Probabilities",
              ylab = "Observed Probabilities", main = "", ...) {
    if (!is.data.frame(newdata) || nrow(newdata) == 0)
        stop("'newdata' must be a data.frame with more than one rows.\n")
    if (is.null(Thoriz) && is.null(Dt))
        stop("either 'Thoriz' or 'Dt' must be non null.\n")
    if (!is.null(Thoriz) && Thoriz <= Tstart)
        stop("'Thoriz' must be larger than 'Tstart'.")
    if (is.null(Thoriz))
        Thoriz <- Tstart + Dt
    type_censoring <- object$model_info$type_censoring
    Tstart <- Tstart + 1e-06
    Thoriz <- Thoriz + 1e-06
    mframe <- model.frame(object$terms, data = newdata)
    Y <- model.response(mframe)
    Time <- Y[, 'time']
    newdata <- newdata[Time >= Tstart, ]
    mframe <- model.frame(object$terms, data = newdata)
    Y <- model.response(mframe)
    Time <- Y[, 'time']
    event <- Y[, 'status']
    sfit0 <- summary(survfit(object, newdata = newdata), times = Tstart)
    sfit <- summary(survfit(object, newdata = newdata), times = Thoriz)
    pi_u_t <- 1.0 - (as.matrix(sfit$surv)[1L, ] / as.matrix(sfit0$surv)[1L, ])
    cloglog <- function (x) log(-log(1.0 - x))
    cal_DF <- data.frame(Time = pmin(Thoriz, Time),
                         event = event * (Time <= Thoriz), preds = pi_u_t)
    if (is.null(df_ns)) {
        df_ns <- if (sum(cal_DF$event) > 25L) 3L else 2L
    } else {
        if (!is.numeric(df_ns) || length(df_ns) != 1L)
            stop("'df_ns' must be a numeric scalar.")
    }
    form <- paste0("Surv(Time, event) ~ nsk(cloglog(preds), df = ", df_ns, ")")
    cal_Cox <- coxph(as.formula(form), data = cal_DF)
    qs <- quantile(pi_u_t, probs = c(0.01, 0.99))
    probs_grid <- data.frame(preds = seq(qs[1L], qs[2L], length.out = 101L))
    ss <- summary(survfit(cal_Cox, newdata = probs_grid), times = Thoriz)
    obs <- 1 - c(ss$surv)
    low <- 1 - c(ss$low)
    upp <- 1 - c(ss$upp)
    obs_pi_u_t <- 1 - c(summary(survfit(cal_Cox, newdata = cal_DF),
                                times = Thoriz)$surv)
    preds <- probs_grid$preds
    if (plot) {
        plot(preds, obs, type = "n", xlab = xlab, ylab = ylab, main = main,
             xlim = c(0, 1), ylim = c(0, 1))
        if (add_CI) {
            polygon(c(preds, rev(preds)), c(low, rev(upp)), border = NA,
                    col = col_CI)
        }
        lines(preds, obs, lty = lty, col = col, lwd = lwd)
        abline(0, 1, lty = 2)
        if (add_density) {
            par(new = TRUE)
            plot(density(pi_u_t), axes = FALSE, xlab = "", ylab = "", main = "",
                 col = col_dens)
        }
        invisible()
    } else {
        list("observed" = obs, "predicted" = preds, "pi_u_t" = pi_u_t,
             "obs_pi_u_t" = obs_pi_u_t, "low" = low, "upp" = upp)
    }
}
