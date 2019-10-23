args <- commandArgs(trailingOnly = TRUE)

linear_regression = function(x,grp){
	lm_model = lm(x~grp)
	coefficient_unadjusted = coefficients(summary(lm_model))[,1][2]
	unadjusted_P = coefficients(summary(lm_model))[,4][2]
	unadjusted_stats = cbind(coefficient_unadjusted,unadjusted_P)
}

linear_regression_adjusted = function(x,grp,sv){
	adjusted_lm_model = lm(x~grp+sv)
	adjusted_coefficient_unadjusted = coefficients(summary(adjusted_lm_model))[,1][2]
	adjusted_P = coefficients(summary(adjusted_lm_model))[,4][2]
	adjusted_stats = cbind(adjusted_coefficient_unadjusted,adjusted_P)
}

run_sva = function(DataDir,ExpressionFileName,DemographicFileName,SvaMethod,Surrogate_variable=mySurrogate_variable,Probe_statistics=myProbe_statistics,Probe_statistics_significants=myProbe_statistics_significants,Adjustedpng=myAdjusted,Unadjustedpng=myUnadjusted){

	library(sva) 

	a = as.matrix(read.table(ExpressionFileName,header=T,row.names=1)) 
	b = read.table(DemographicFileName,header=T,row.names=1) 
	s=a
	grp = b[,1] 
	stats = apply(s, 1, function(x) linear_regression(x,grp))
	tstats = t(stats)
	p_unadjusted = tstats[,2]
	coefficient_unadjusted = tstats[,1]
	
	mod = cbind(rep(1,length(grp)),grp) 
	mod0 = cbind(rep(1,length(grp))) 

	cases = length(grp[grp==1])
	controls = length(grp[grp==0])
	
	cases.m = apply(s[,1:cases],1,mean) 
	controls.m = apply(s[,controls:length(grp)],1,mean) 
	
	fold_change_u = 2^coefficient_unadjusted 
	h = cbind(fold_change_u)
	fold_change_up_or_down_regulated_unadjusted = apply(h, 1, function(x) if(x[1]<1) x[1]=-(1/x[1]) else x[1]=x[1]) 	

	svaobj = sva(s,mod,mod0,method=SvaMethod) 

	write.table(svaobj$sv,Surrogate_variable, sep = "\t") 
	write.table(a,"sva-data.txt", sep = "\t") 
	write.table(b,"sva-dx.txt", sep = "\t")  

	stats_a = apply(s, 1, function(x) linear_regression_adjusted(x,grp,svaobj$sv))
	tstats_a = t(stats_a)
	p_adjusted = tstats_a[,2]
	coefficient_adjusted = tstats_a[,1]
	mod.sv = cbind(mod, svaobj$sv) 
	mod0.sv = cbind(mod0, svaobj$sv) 
	
	fold_change_a = 2^coefficient_adjusted 
	h = cbind(fold_change_a)
	fold_change_up_or_down_regulated_adjusted = apply(h, 1, function(x) if(x[1]<1) x[1]=-(1/x[1]) else x[1]=x[1]) 
	
	e = cbind(coefficient_unadjusted,fold_change_up_or_down_regulated_unadjusted,p_unadjusted,coefficient_adjusted,fold_change_up_or_down_regulated_adjusted,p_adjusted)
	edf = data.frame(e)
	e_significants = subset(edf, p_adjusted<0.05)

	write.table(e,Probe_statistics, sep = "\t") 
	write.table(e_significants,Probe_statistics_significants, sep = "\t") 

	p_unadjusted.trans = -1 * log(p_unadjusted) 
	p_adjusted.trans = -1 * log(p_adjusted) 

	M=coefficient_unadjusted
	M_a=coefficient_adjusted

	png(Unadjustedpng, width = 1400, height = 800)
	par(mfrow = c(1, 3),pty = "s")

	#volcano plot
	plot(range(M),range(p_unadjusted.trans),type="n",ylab="-log10(p-value_unadjusted)",xlab="M",main="Unadjusted Volcano Plot") 
	points(M,p_unadjusted.trans,col="black",cex=0.2, pch=16)
	points(M[(p_unadjusted.trans > 1.3 & M > 1)],p_unadjusted.trans[(p_unadjusted.trans > 1.3 & M > 1)],col="red",pch=16) 
	points(M[(p_unadjusted.trans > 1.3 & M < -1)],p_unadjusted.trans[(p_unadjusted.trans > 1.3 & M < -1)],col="green",pch=16) 
	abline(h = 1.3)
	abline(v = -1)
	abline(v = 1)

	#ma plot
	a = (cases.m + controls.m)/2.0
	plot(range(a),range(coefficient_unadjusted),type="n",ylab="M",xlab="A",main="MA Plot") 
	points(a,coefficient_unadjusted,col="black",cex=0.2, pch=16)
	points(a[(coefficient_unadjusted > 1)],coefficient_unadjusted[(coefficient_unadjusted > 1)],col="red",pch=16) 
	points(a[(coefficient_unadjusted < -1)],coefficient_unadjusted[(coefficient_unadjusted < -1)],col="green",pch=16) 
	abline(h = -1)
	abline(h = 1)

	hist(p_unadjusted, main = "Unajusted P-values", xlab = "P-value", col = "grey")
	
	dev.off()

	svdemo = cbind(svaobj$sv,b)	

	png(Adjustedpng, width = 1400, height = 800)

	par(mfrow = c(1, 3),pty = "s")

	#volcano plot
	plot(range(M_a),range(p_unadjusted.trans),type="n",ylab="-log10(p-value_adjusted)",xlab="M",main="adjusted Volcano Plot") 
	points(M_a,p_adjusted.trans,col="black",cex=0.2, pch=16)
	points(M_a[(p_adjusted.trans > 1.3 & M_a > 1)],p_adjusted.trans[(p_adjusted.trans > 1.3 & M_a > 1)],col="red",pch=16) 
	points(M_a[(p_adjusted.trans > 1.3 & M_a < -1)],p_adjusted.trans[(p_adjusted.trans > 1.3 & M_a < -1)],col="green",pch=16) 
	abline(h = 1.3)
	abline(v = -1)
	abline(v = 1)

	#ma plot
	a = (cases.m + controls.m)/2.0
	plot(range(a),range(coefficient_adjusted),type="n",ylab="M",xlab="A",main="MA Plot") 
	points(a,coefficient_adjusted,col="black",cex=0.2, pch=16)
	points(a[(coefficient_adjusted > 1)],coefficient_adjusted[(coefficient_adjusted > 1)],col="red",pch=16) 
	points(a[(coefficient_adjusted < -1)],coefficient_adjusted[(coefficient_adjusted < -1)],col="green",pch=16) 
	abline(h = -1)
	abline(h = 1)

 	hist(p_adjusted, main = "Adjusted P-values", xlab = "P-value", col = "grey")

	dev.off()
}

myExpressionFileName=args[1]
myDemographicFileName=args[2]
mySurrogate_variable=args[3]
myProbe_statistics=args[4]
myProbe_statistics_significants=args[5]
myAdjusted=args[6]
myUnadjusted=args[7]
mySVA_Method=args[8]

run_sva(DataDir="",ExpressionFileName=myExpressionFileName,DemographicFileName=myDemographicFileName,SvaMethod=mySVA_Method,Surrogate_variable=mySurrogate_variable,Probe_statistics=myProbe_statistics,Probe_statistics_significants=myProbe_statistics_significants,Adjustedpng=myAdjusted,Unadjustedpng=myUnadjusted)



