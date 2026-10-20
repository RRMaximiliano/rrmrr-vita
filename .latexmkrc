# Build with XeLaTeX (fontspec) and refresh the git version info first.
$pdf_mode = 5;
system('sh', 'vc.sh') == 0 or warn "vc.sh failed; the footer will show the build date\n";
