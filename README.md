# MeerkatReader
OCR for plotwatcher video date, time, and camera ID extraction.

Aim:

Extracting timestamps, IDs, and dates from camera images. The images 
are reasonably low quality. 

<https://lh3.googleusercontent.com/-66Gdv6G7X0g/WGb-C3y-fII/AAAAAAAAGcY/-dTJCKLEqXYF4Oc-PkzTzR970_qIyN86wCLcB/s1600/FH441_01_001.jpg>
The region is cropped, thresholded and resized. Resized to a height of 
about 120 pixels (seems to work better than 50)

<https://lh3.googleusercontent.com/-4Diy81WQXBE/WGb_UaHIhlI/AAAAAAAAGck/tT4c93Ylg4oZ48B3zQSaWA5NKBTZZZqWQCLcB/s1600/figure_1.png>
Filled in with morphological operations:

<https://lh3.googleusercontent.com/-0IU3Ec0UBGE/WGb_qzIikaI/AAAAAAAAGcs/EhfG9O3kg10MAcrCdfCQ7Z_7R4Tyl2jKACLcB/s1600/figure_1-2.png>

Contour analysis to identify individual letters

<https://lh3.googleusercontent.com/-XIATeLYYJN4/WGcAXLqJqrI/AAAAAAAAGc4/envmjHxT8lUlMi00t-bUTpHPQq99m9EPACLcB/s1600/figure_1-4.png>

or

<https://lh3.googleusercontent.com/-mq1QSW4vo7U/WGcA0wJN0tI/AAAAAAAAGdA/gj8-72IBFl87bDV7A33sqMrNYQ_VgFg8ACLcB/s1600/figure_1-3.png>

