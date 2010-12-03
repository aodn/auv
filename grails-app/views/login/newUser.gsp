<%@ page contentType="text/html;charset=UTF-8" %>

 <html>
   <head>

<title>Create new Login Page</title>

        <link rel="stylesheet" type="text/css" href="${resource(dir:'css',file:'base.css')}"/>
        <link rel="stylesheet" type="text/css" href="${resource(dir:'css',file:'login.css')}"/>
        <script type="text/javascript" src="${resource(dir:'js',file:'jquery-1.4.2.min.js')}"></script>

        <link rel="shortcut icon" href="${resource(dir:'images',file:'favicon.ico')}" type="image/x-icon" />
</head>

<body>

<div class="body">



  <div class="dialog">
  <h3>Please enter your details below:</h3>

  
  <div class="message">${flash.message}</div>
  
  <g:hasErrors bean="\${${propertyName}}">
  <div class="errors">
      <g:renderErrors bean="\${${propertyName}}" as="list" />
  </div>
  </g:hasErrors>
  


  <g:form action="save" method="post">
                <div class="dialog">
                    <table>
                        <tbody>

                            <tr class="prop">

                                <td valign="top" class="name">
                                    <label for="title">Title</label>
                                </td>
                                <td valign="top" class="value ">
                                    <select name="title" id="title" >
<option value="Mr" >Mr</option>
<option value="Mrs" >Mrs</option>
<option value="Ms" >Ms</option>
<option value="Dr" >Dr</option>
<option value="Professor" >Professor</option>
</select>
                                </td>
                            </tr>

                            

                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="email">Email Address</label>
                                </td>
                                <td valign="top" class="value ">
                                    <input type="text" name="email" value="" id="email" />
                                </td>

                            </tr>

                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="firstname">Firstname</label>
                                </td>
                                <td valign="top" class="value ">
                                    <input type="text" name="firstname" value="" id="firstname" />
                                </td>

                            </tr>

                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="surname">Surname</label>
                                </td>
                                <td valign="top" class="value ">
                                    <input type="text" name="surname" value="" id="surname" />
                                </td>

                            </tr>


                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="password">Password</label>
                                </td>
                                <td valign="top" class="value ">
                                    <input name="password" type="password" maxlength="15" value=""  />
                                </td>

                            </tr>
                             <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="password">Password again</label>
                                </td>
                                <td valign="top" class="value ">
                                    <input name="password2" type="password" maxlength="15" value=""  />
                                </td>

                            </tr>

                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="org">Organisation</label>
                                </td>
                                <td valign="top" class="value ">
                                    <input type="text" name="org" value="" id="org" />
                                </td>

                            </tr>

                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="kind">Organisation Kind</label>
                                </td>

                                <td valign="top" class="value ">
                                    <select name="kind" id="kind" >
<option value="Government" >Government</option>
<option value="NGO" >NGO</option>
<option value="University" >University</option>
<option value="Private Sector" >Private Sector</option>
<option value="Volunteer" >Volunteer</option>
</select>
                                </td>

                            </tr>


                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="address">Address</label>
                                </td>
                                <td valign="top" class="value ">
                                    <input type="text" name="address" value="" id="address" />
                                </td>

                            </tr>

                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="country">Country</label>
                                </td>
                                <td valign="top" class="value ">
                                    <input type="text" name="country" value="" id="country" />
                                </td>

                            

                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="zip">Postcode/Zip</label>
                                </td>
                                <td valign="top" class="value ">
                                    <input type="text" name="zip" value="" id="zip" />
                                </td>

                            </tr>

                        </tbody>
                    </table>
                </div>
                <div class="buttons">
                    <span class="button"><input type="submit" name="create" class="save" value="Create" id="create" /></span>
    <span class="button"><button  type="button"  value='Cancel'  onclick="Javascript:history.back();"  >Cancel</button></span>    
                </div>
            </g:form>



  </div>
  



<h4 class="error">
${flash.message}
</h4>


</div>

</body>
 </html>


