#' Compare function
#'
#' Function \code{compare} is a generic function used to assess the quality of 
#' the model-based estimates by comparing them with the direct estimates.
#'
#' @param model an object of type "emdi","model".
#' @param ... further arguments passed to or from other methods.
#' @return The return of \code{compare} depends on the class of its argument. The
#' documentation of particular methods gives detailed information about the
#' return of that method.
#' @export

compare <- function(model, ...) UseMethod("compare")


#' Compare function
#'
#' Method \code{compare.fh} assesses the quality of the model-based estimates by 
#' comparing them with the direct estimates based on a goodness-of-fit test 
#' proposed by \cite{Brown et al. (2001)} and by computing the correlation between the 
#' regression-synthetic part of the Fay-Herriot model and the direct estimates.
#'
#' @param model an object of type "model","fh".
#' @param ... further arguments passed to or from other methods.
#' @return The null hypothesis, the value W of the test statistic, the degrees 
#' of freedom and the p value of the Brown test; and the correlation coefficient 
#' of the synthetic part and the direct estimator \cite{(Chandra et al. 2015)}.
#' @references 
#' Brown, G., R. Chambers, P. Heady, and D. Heasman (2001). Evaluation of small 
#' area estimation methods: An application to unemployment estimates from the UK
#' LFS. Symposium 2001 - Achieving Data Quality in a Statistical Agency: A 
#' Methodological Perspective, Statistics Canada. \cr \cr
#' Chandra, H., Salvati, N. and Chambers, R. (2015), A Spatially 
#' Nonstationary Fay-Herriot Model for Small Area Estimation, Journal 
#' of the Survey Statistics and Methodology, 3, 109-135.
#' @export
#' @importFrom stats cor pchisq

compare.fh <- function(model, ...){

  if (!inherits(model, "fh")) {
    stop('Object needs to be of class fh.')
  }
  if (is.null(model$MSE$FH)) {
     testresults <- NULL
      cat('The fh object does not contain MSE estimates. The Brown test 
          statistic cannot be computed.', "\n")
   } else {
  W_BL <- sum((model$ind$Direct[model$ind$Out == 0] - 
                 model$ind$FH[model$ind$Out == 0])^2 /
              (model$MSE$Direct[model$MSE$Out == 0] + 
                 model$MSE$FH[model$MSE$Out == 0]))
  
 # Degress of freedom
 df_BL <- model$framework$N_dom_smp
 
 # p Value
 p_value_BL <- 1 - pchisq(W_BL, df_BL)
 
 testresults <- data.frame(W.value = W_BL,
                           Df = df_BL,
                           p.value = p_value_BL)
   }
 
 # Extraction of the regression part
 if (!is.null(model$model$gamma)) {
    xb <- (model$ind$FH[model$ind$Out == 0] - 
             model$model$gamma$Gamma[model$ind$Out == 0] *
             model$ind$Direct[model$ind$Out == 0]) /
       (1 - model$model$gamma$Gamma[model$ind$Out == 0]) 
 } 
 if (is.null(model$model$gamma)) {
   xb <- model$ind$FH[model$ind$Out == 0] - 
    model$model$random_effects
 }
   
   
 # Direct estimator
 direct_insample <- model$ind$Direct[model$ind$Out == 0]
 # Correlation
 syndircor <- cor(xb, direct_insample)
   
 results <- list(Brown = testresults, syndir = syndircor)
 
 class(results) <- "compare.fh"
 
 if (model$framework$N_dom_unobs > 0) {
   cat("Please note that the computation of both test statistics is only based 
       on in-sample domains.","\n")
 }
 return(results)
}

#' Prints compare.fh objects
#' 
#' compare.fh object is printed.
#'
#' @param x an object of type "compare.fh".
#' @param ... further arguments passed to or from other methods.
#' @export

print.compare.fh <- function(x, ...)
{
   if (!(is.null(x$Brown))) {
      cat("Brown test","\n")
      cat("\n")
      cat("Null hypothesis: EBLUP estimates do not differ significantly from the 
      direct estimates","\n")
      cat("\n")
      print(data.frame(W.value = x[[1]]$W,
                       Df = x[[1]]$Df,
                       p.value = x[[1]]$p.value,
                       row.names = ""))
      if (length(x) == 2) {
         cat("\n")
         cat("Correlation between synthetic part and direct estimator: ", 
             round(x[[2]], 2),"\n")
      }
   } else {
      if (length(x) == 2) {
         cat("\n")
         cat("Correlation between synthetic part and direct estimator: ", 
             round(x[[2]], 2),"\n")
      }
   }
  
}




