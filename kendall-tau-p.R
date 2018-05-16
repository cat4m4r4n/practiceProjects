#kendall tau significance uses z score
#calculate z score

#function to calculate z from kendall's tau
tau_to_z <- function(n, tau, alpha){
  #tau to z
  numerator <- 3 * tau * (sqrt(n*(n-1)))
  denominator <- (sqrt(2*(2*n+5)))
  z <- numerator/denominator
  #z to p crit
  z.half.alpha = qnorm(1-alpha/2)
  pcrit <-c(-z.half.alpha, z.half.alpha)
  #pval two-tailed
  pval <- c(2 * pnorm(z, lower.tail=FALSE))
  pval <- round(pval, 6)
  
  #generate significance stars
  stars <- c(ifelse(pval < .001, "***", ifelse(pval < .01, "**", ifelse(pval < .05, "*", ""))))
  starstext <-"p < .0001 ‘****’; p < .001 ‘***’, p < .01 ‘**’, p < .05 ‘*’"

  pval<-(paste0(pval,stars))
  pval <-matrix(pval, nrow=nrow(z), ncol=(ncol(z)))
  rownames(pval) <- rownames(z)
  colnames(pval) <- colnames(z)
  
  #save to list to return multiple objects. lefthand is the label
  results <-list(zscore=z, pcrit=pcrit, pval_test = pval, sig=starstext)
  #results <-list(zscore=z, pcrit=pcrit, pval=paste0(pval,stars), sig=starstext)

  return(results)
}

#test
#tau_to_z(n=878, tau=ken, alpha = 0.05)

#kendall's tau is (concordant num of pairs - num of discordant pairs) / (num concordant pairs + num of discordant pairs)
#z = (3*tau*(sqrt(n(n-1))))/(sqrt(2(2n+5)))

#cor.test(var1, var2, method = "kendall")
#also can accept dataset instead of vars

