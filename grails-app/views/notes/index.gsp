<!--
  To change this template, choose Tools | Templates
  and open the template in the editor.
-->




<html>
    <head>
        <title>IMOS AUV Image Note Editor</title>
        <link rel="stylesheet" type="text/css" href="${resource(dir:'css',file:'base.css')}"/>
        <link rel="stylesheet" type="text/css" href="${resource(dir:'css',file:'notes.css')}"/>
        <link rel="stylesheet" type="text/css" href="${resource(dir:'js/jquery.imgareaselect-0.9.2/css',file:'imgareaselect-default.css')}" />
        
        <meta name="layout" content="main" />


        <script type="text/javascript" src="${resource(dir:'js',file:'jquery-1.4.2.min.js')}"></script>
        <script type="text/javascript" src="${resource(dir:'js/jquery.imgareaselect-0.9.2/scripts',file:'jquery.imgareaselect.js')}" ></script>


        <link rel="shortcut icon" href="${resource(dir:'images',file:'favicon.ico')}" type="image/x-icon" />
        <script type="text/javascript" >

            // this will be parsed in
            var image = "http://imos2.ersa.edu.au/AUV/WA201004/r20100422_040822_rottnest_06_15m_n_out/i2jpg/PR_20100422_050712_741_LC16.jpg";
            image = "http://localhost/S2_Hero_Code2Cloud.png";


            var photo; // instance of the imgAreaSelect object
            jQuery.noConflict();

            jQuery(document).ready(function () {
                photo = jQuery('img#photo').imgAreaSelect({
                    instance: true, //
                    handles: true,
                    aspectRatio: '1:1',
                    fadeSpeed: "200",
                    onSelectEnd: setFormElements,
                    onSelectChange: preview
                });

                 jQuery('#photo').attr("src", image);
                 jQuery('#photoThumb').attr("src", image);
                 jQuery('#imageFilename').val(image);
            });

 
            function preview(img, selection) {

                var scaleX = 100 / (selection.width || 1);
                var scaleY = 100 / (selection.height || 1);

                jQuery('#selectionThumbnail > img').css({
                    width: Math.round(scaleX * jQuery('#photo').width()) + 'px',
                    height: Math.round(scaleY * jQuery('#photo').height()) + 'px',
                    marginLeft: '-' + Math.round(scaleX * selection.x1) + 'px',
                    marginTop: '-' + Math.round(scaleY * selection.y1) + 'px'

                });
            }

            function setFormElements(img, selection) {

                if (selection.height < 20 || selection.width < 20) {
                    photo.setOptions({hide:true});
                    alert("Click and drag to create an area to annotate");
                    jQuery('#newNoteForm').hide();
                }
                else {
                    // show the form with the hidden magic
                    jQuery('#newNoteForm').show(500);
                    var width = selection.width;
                    var height = selection.height;
                    jQuery('#imageX1').val(selection.x1);
                    jQuery('#imageX2').val(selection.x2);
                    jQuery('#imageY1').val(selection.y1);
                    jQuery('#imageY2').val(selection.y2);

                };
            };

           

        </script>

</head>
<body>

<h2>Add a note to this image</h2>
<h5>Click and drag an area to annotate</h5>

<div class="photoDiv">
<img src="" alt="image to annotate" id="photo"/></div>

<div style="clear:both" ></div>



<div id="newNoteForm" style="display:none" >

  <div id="selectionThumbnail" >
    <img  src="" id="photoThumb" alt="area of the image to annotate" />
</div>
    <label for="newNote" >Add a Note:</label>
    <g:form  name="myForm" url="[action:'submitNote',controller:'notes']" >

    <g:textArea id="newNote" name="newNote" cols="30" rows="3" ></g:textArea>
    <input name="imageX1" id ="imageX1" type="hidden" />
    <input name="imageX2" id ="imageX2" type="hidden" />
    <input name="imageY1" id ="imageY1" type="hidden" />
    <input name="imageY2" id ="imageY2" type="hidden" />
    <input name="imageFilename" id ="imageFilename" type="hidden" />
    <BR>
    <button  type="submit" >Add Note</button>
</g:form>

</div>


<div style="clear:both" ></div>
<div id="current_notes">${flash.message}  
<g:each in="${currentnotes}" var="tes" >     
  <div>
           <h5>${tes.datetime} </h5>
           <div class="notearea">${tes.note}</div>
  </div>
     
  </g:each>
</div>


</body>
</html>



