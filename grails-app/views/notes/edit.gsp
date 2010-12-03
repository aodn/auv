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

                

                // when enter is pressed inside the note textarea, submit form
                jQuery(function() {
                      jQuery("form #editedNote").keypress(function (e) {
                          if ((e.which && e.which == 13) || (e.keyCode && e.keyCode == 13)) {
                              jQuery('#editNoteSubmit').click();
                              //return false;
                          } else {
                              return true;
                          }
                      });
                  });

// set the existing note bounding boxes
                  setNotesArea();


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
                    jQuery('#newNoteForm').hide();
                    alert("Click and drag to create an area to annotate");
                }
                else {
                    
                    jQuery('#newNote').focus();
                    
                    jQuery('#imageX1').val(selection.x1);
                    jQuery('#imageX2').val(selection.x2);
                    jQuery('#imageY1').val(selection.y1);
                    jQuery('#imageY2').val(selection.y2);
                    jQuery('#width').val(selection.width);
                    jQuery('#height').val(selection.height);



                }

            };



            function setNotesArea() {

              photo = jQuery('img#photo').imgAreaSelect({
                    instance: true, //
                    handles: false,
                    aspectRatio: '1:1',
                    x1:  ${theNote.imagex1},
                    x2:  ${theNote.imagex2},
                    y1:  ${theNote.imagey1},
                    y2:  ${theNote.imagey2}
                });

            }





        </script>

</head>
<body>

<h2 class="edit" >Edit your existing note</h2>
<h5>Click and drag an area to annotate</h5>

<div class="photoDiv">
    <img src="${session.imageUrl}" alt="image to annotate" id="photo"  />
</div>





<div style="clear:both" ></div>


<h2 class="highlight">${flash.message}</h2>
<div id="newNoteForm" >

  <div id="selectionThumbnail" >
    <img  src="${session.imageUrl}" id="photoThumb" alt="area of the image to annotate" />
</div>
    <label for="newNote" >Edit Note:</label>
    <g:form  name="noteForm" id="noteForm" url="[action:'editNote',controller:'notes']" >

    <g:textArea id="editedNote" name="editedNote" cols="30" rows="3" >${theNote.note}</g:textArea>
    <input name="id" value="${theNote.id}" type="hidden" />
    <input name="imageX1" id ="imageX1" value="${theNote.imagex1}" type="hidden" />
    <input name="imageX2" id ="imageX2" value="${theNote.imagex2}" type="hidden" />
    <input name="imageY1" id ="imageY1" value="${theNote.imagey1}" type="hidden" />
    <input name="imageY2" id ="imageY2" value="${theNote.imagey2}" type="hidden" />
    <input name="width" id ="width" value="${theNote.width}" type="hidden" />
    <input name="height" id ="height" value="${theNote.height}" type="hidden" />
    <input name="imageFilename" id ="imageFilename" value="${session.imageUrl}" type="hidden" />
    <BR>
    <button  type="submit" id="editNoteSubmit" >Edit Note</button> &nbsp;
    <button  type="button"  value='Cancel'  onclick="Javascript:history.back();"  >Cancel</button>
</g:form>

</div>





</body>
</html>



