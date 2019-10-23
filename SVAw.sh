#!/bin/bash

usage()
{
cat << EOF
usage: $0 options
   options:
     -e  Expression Filename                     (required)
     -d  Demographic Filename                    (required)
     -v  Surrogate Variable Filename             (optional) default: Surrogate_Variable.txt
     -p  Probe Statistics Filename               (optional) default: Probe_Statistics.txt
     -s  Probe Statistics Significants Filename  (optional) default: Probe_Statistics_Significants.txt
     -u  Unadjusted Graph Filename               (optional) default: Unadjusted_Graph.png
     -a  Adjusted Graph Filename                 (optional) default: Adjusted_Graph.png
     -m  SVA Method                              (optional) default: irw
     -o  output folder                           (optional) default: SVAw_output
EOF
}


echo -e "
|----------------------------------------------|
|     SVAw v1.0    release: 2/29/2012          |
|----------------------------------------------|
|  For questions & comments:                   |
|     http://psychiatry.igm.jhmi.edu/sva/      |
|----------------------------------------------|
"




NO_ARGS=0
Surrogate_Variable_Filename="Surrogate_Variable.txt"
Probe_Statistics_Filename="Probe_Statistics.txt"
Probe_Statistics_Significants_Filename="Probe_Statistics_Significants.txt"
Unadjusted_Graph_Filename="Unadjusted_Graph.png"
Adjusted_Graph_Filename="Adjusted_Graph.png"
SVA_Method="irw"
output_folder="SVAw_output"

while getopts e:d:v:p:s:u:a:m: OPT; do
    case "$OPT" in
    	e)
		Expression_Filename=$OPTARG 
		;;
    	d)
		Demographic_Filename=$OPTARG 
		;;
    	v)
		Surrogate_Variable_Filename=$OPTARG 
		;;
    	p)
		Probe_Statistics_Filename=$OPTARG 
		;;
    	s)
		Probe_Statistics_Significants_Filename=$OPTARG 
		;;
    	u)
		Unadjusted_Graph_Filename=$OPTARG 
		;;
    	a)
		Adjusted_Graph_Filename=$OPTARG 
		;;
    	m)
		SVA_Method=$OPTARG 
		;;
    	o)
		output_folder=$OPTARG 
		;;
    	?)
     		usage
     		exit
		;;
  	esac
done


if  [[ -z $Expression_Filename ]] || [[ -z $Demographic_Filename ]] || [ $# -eq "$NO_ARGS" ]    #  invoked with no command-line args
then
     usage
     exit 1
fi  



R --no-restore --no-save --args $Expression_Filename  $Demographic_Filename  \
    $Surrogate_Variable_Filename  \
    $Probe_Statistics_Filename    \
    $Probe_Statistics_Significants_Filename    \
    $Adjusted_Graph_Filename    \
    $Unadjusted_Graph_Filename   \
    $SVA_Method   \
     < sva.R   >   out.log

if [ ! -d "$output_folder" ]; then
    mkdir $output_folder
fi

mv  -f   $Surrogate_Variable_Filename    $output_folder/
mv  -f   $Probe_Statistics_Filename      $output_folder/
mv  -f   $Probe_Statistics_Significants_Filename     $output_folder/
mv  -f   $Adjusted_Graph_Filename     $output_folder/
mv  -f   $Unadjusted_Graph_Filename     $output_folder/
mv  -f   sva-data.txt     $output_folder/
mv  -f   sva-dx.txt     $output_folder/
mv  -f   out.log     $output_folder/

echo -e "
Analysis completed! 

Creating output folder: $output_folder

Generating report ..."

echo -e "<!DOCTYPE html>
<html lang=\"en\">
<head>
<meta charset=\"utf-8\">
<title>SVAw report</title>
<style>
#wrap { width: 960px; margin: 0 auto; text-align: center; }
body { background: color: #555; line-height: 24px; font: 13px/21px \"Helvetica Neue\", Helvetica, Arial, sans-serif; text-align: center; }
h1 { font-size: 30px; margin: 10px 0 10px 0; }
h2 { font-size: 20px; margin: 10px 0 10px 0; }
h3 { font-size: 17px; margin: 10px 0 10px 0; }
h4 { font-size: 16px; font-style: italic; margin: 30px 0 10px 0; }
h5 { font-size: 14px; margin: 20px 0 10px 0; }
h6 { font-size: 12px; margin: 20px 0 10px 0; }
a { color: #F34607; text-decoration: none; }
a:hover { color: #222; }
em { font-style: italic; }
ol, ul { list-style: none; }
p { margin: 0 0 15px 0; }
.title { margin: 0 0 15px 0; line-height: 30px; font-size: 18px; font-weight: bold; }
.no-top-margin { margin-top: 0; }
.cache-images { display: none; }
.line { clear: both; border-bottom: 2px solid #eee; margin-bottom: 45px;  }
.hide { display: none; }
#main { float: left; padding: 10px 0 0 0; width: 100%; margin: 10px 0 10px; }
#content { float: left; width: 800px; padding: 0 100px 40px 2px; text-align: left; margin: -10px 0 0 0; }
#header { padding: 60px 0 0 0; overflow: hidden; }
#header h1 { color: #555; letter-spacing: -1px; font-weight: bold; font-size: 38px; margin: 0 0 14px 0; }
#header h2 { color: #ccc; font-size: 26px; letter-spacing: -1px; margin: 0; font-weight: normal; }
#nav { float: left; width: 100%; overflow: hidden; position: relative; margin: 10px 0 10px 0; border-bottom: 1px #eee dotted; padding: 10px 0 8px 0; }
#nav ul { clear: left; float: left; margin: 0; padding: 0; position: relative; left: 50%; text-align: center; }
#nav ul li { float: left; list-style: none; margin: 0; padding: 0; position: relative; right: 50%; }
#nav ul li a { margin: 0 0 0 1px; padding: 0; font-size: 14px; color: #666; text-transform: uppercase; }
#nav ul li a:hover { color: #F34607; }
#nav li span { padding: 0 18px; color: #666; font-size: 14px; }
#nav li .current { color: #F34607; }
.frontpage { margin: 0 0 80px 0 !important; }
#photo-gallery { border: 1px #eee solid; position: relative; height: 390px; width: 700px; margin: 40px auto 70px; background: #f5f5f5; }
#photo-gallery img { margin: 5px 0 0 0; }
.article { margin: 0 0 45px 0; }
.article .title { margin: 0 0 -2px 0; font-size: 18px; }
.article p.meta { font-size: 16px; margin: 0 0 15px 0; color: #aaa; }
.next-articles { margin: 0 0 0 0; }
.more-link { display: block; margin: 20px 0 0 0; }
#footer { clear: both; font-size: 14px; color: #888; padding: 0 0 20px 0; }
#footer .copyright { text-align: center; padding: 8px 0 0 0; }
.footer-line { border-bottom: 2px solid #eee; }
</style></head><body>
<div id=\"wrap\">
<div id=\"header\">
<h2>SVAw analysis output</h2>
<div id=\"nav\">
</div><!--end nav-->
</div><!--end header-->
<div id=\"main\">
<div id=\"content\">
<h3 class=\"title\">Input Files:</h3>
<p><b>Expression File:</b> <a href=\"sva-data.txt\">Expression File (sva-data.txt)</a><br />
<b>Disease/Condition Status:</b> <a href=\"sva-dx.txt\">Demographic File: (sva-dx.txt)</a></p> 

<h3 class=\"title\">Output Files:</h3> 
<p><b>Surrogate Variables:</b> <a href=\"$Surrogate_Variable_Filename\">$Surrogate_Variable_Filename</a><br />
<b>Probe Statistics:</b> <a href=\"$Probe_Statistics_Filename\">$Probe_Statistics_Filename</a><br />
<b>Probe Statistics (Significants):</b> <a href=\"$Probe_Statistics_Significants_Filename\">$Probe_Statistics_Significants_Filename</a><br />
<b>Analysis log file: </b> <a href=\"out.log\">out.log</a>&nbsp;</p>
<p><b>Plots of unadjusted values:</b> <a href=\"$Unadjusted_Graph_Filename\">$Unadjusted_Graph_Filename</a><br />
<a href=\"$Unadjusted_Graph_Filename\"><img src=\"$Unadjusted_Graph_Filename\" alt=\"[$Unadjusted_Graph_Filename]\" id=\"photo-gallery\" /></a></p>
<p><b>Plots after SVA adjustment:</b> <a href=\"$Adjusted_Graph_Filename\">$Adjusted_Graph_Filename</a><br />
<a href=\"$Adjusted_Graph_Filename\"><img src=\"$Adjusted_Graph_Filename\" alt=\"[$Adjusted_Graph_Filename]\" id=\"photo-gallery\" /></a></p>
<p>&nbsp;</p>

</div><!--end content--><!--end sidebar-->
</div><!--end main-->
<div id=\"footer\">
<div class=\"footer-line\"></div>
<p class=\"copyright\">Copyright &copy; 2012 &middot; [<a href=\"http://psychiatry.igm.jhmi.edu/sva/\">SVAw</a>] &middot; All Rights Reserved</p>
</div><!--end footer-->
</div> <!--end wrap-->
</body>
</html>
"  >  $output_folder/SVAw_report.htm



echo -e "
open the \"$output_folder/SVAw_report.htm\" in your browser to see the SVAw analysis outcome.
"
















