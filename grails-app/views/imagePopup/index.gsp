<!--*************************************************
  Copyright 2010 IMOS
  The IMOS AUV Viewer is distributed under
  the terms of the GNU General Public License
*************************************************-->



<html>
<head>
    <title>AUV Viewer - Selected Image</title>
    <link rel="stylesheet" href="${resource(dir:'css',file:'base.css')}" />
    <link rel="shortcut icon" href="${resource(dir:'images',file:'favicon.ico')}" type="image/x-icon" />

</head>
<body>

<div class="imagePopupSpacer" >
    <img src="${params.jpg}" alt="${message(code:'spinner.alt',default:'Loading...')}" />
</div>

<g:if test="${params.tiff}" >
<div class="imagePopupFooter" >
    <a href="${params.tiff}" title=""${params.tiff}" >TIFF link</a>
</div>
</g:if>

</body>
</html>
