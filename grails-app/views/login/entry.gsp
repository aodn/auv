<!--
  To change this template, choose Tools | Templates
  and open the template in the editor.
-->

<%@ page contentType="text/html;charset=UTF-8" %>

 <html>

<head>

<title>Login Page</title>

        <link rel="stylesheet" type="text/css" href="${resource(dir:'css',file:'base.css')}"/>
        <link rel="stylesheet" type="text/css" href="${resource(dir:'css',file:'login.css')}"/>
        <script type="text/javascript" src="${resource(dir:'js',file:'jquery-1.4.2.min.js')}"></script>

        <link rel="shortcut icon" href="${resource(dir:'images',file:'favicon.ico')}" type="image/x-icon" />

</head>

<body>

<div class="body">


<g:form action="doLogin" method="post">
  <div class="dialog">
  <h3>Enter your login details below:</h3>
  <table>
  <tr><td>
      <div class="prop ${hasErrors(bean:parent, field:'child.name', 'errors')}">
    <label for="email">Email:</label></td><td><input type="text" name="email" value="${fieldValue(bean:parent,field:'child.name')}" /></td>
</div>
      <!--'${login?.email}' /-->
  </tr>
  <tr><td><label for='password'>Password:</label></td>
    <td><input id="password" type='password' name='password' readonly value="thisisatest"  /></td></tr>
  </table>

  </div>
  <div class="buttons">
  <span >
  <input type="submit" value="Login"></input>
  </span>

    <span class="button"><button  type="button"  value='Cancel'  onclick="Javascript:history.back();"  >Cancel</button></span>   
  </div>
</g:form>

  
  <g:link action="create" >New user register</g:link>


<h4 class="error">
${flash.message}
</h4>

  <g:hasErrors bean="${login}">
  <ul>
   <g:eachError var="err" bean="${login}">
       <li><g:message error="${err}" /></li>
   </g:eachError>
  </ul>
</g:hasErrors>

 <g:renderErrors  as="list" />




</div>

</body>
 </html>

