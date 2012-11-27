<!--*************************************************
  Copyright 2010 IMOS
  The IMOS AUV Viewer is distributed under 
  the terms of the GNU General Public License
*************************************************-->



<html>
    <head>
        <title><g:layoutTitle default="AUV" /></title>
        <link rel="stylesheet" href="${resource(dir:'css',file:'base.css')}" />
        <link rel="shortcut icon" href="${resource(dir:'images',file:'favicon.ico')}" type="image/x-icon" />

        <g:layoutHead />
        
        <g:javascript library="application" />
    </head>
    <body>
     
        <div id="spinner" class="spinner" style="display:none;">
            <img src="${resource(dir:'images',file:'spinner.gif')}" alt="${message(code:'spinner.alt',default:'Loading...')}" />
        </div>
        


       <g:layoutBody />
     
    </body>
</html>