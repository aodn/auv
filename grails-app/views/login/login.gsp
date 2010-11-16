<!--
  To change this template, choose Tools | Templates
  and open the template in the editor.
-->

<%@ page contentType="text/html;charset=UTF-8" %>

 <html>

<head>

<title>Login Page</title>

<meta name="layout" content="main" />


 <link rel="shortcut icon" href="${resource(dir:'images',file:'favicon.ico')}" type="image/x-icon" />

</head>

<body>

<div class="body">

<g:if test="${flash.message}">

<div class="message">



</div>
</g:if>

<p>

${flash.message}

Welcome to Your ToDo List. Login below

</p>

<form action="handleLogin">


<span class='nameClear'><label for="login">

Sign In:

</label>

</span>

g:select name='userName' from="{User.list()}"

optionKey="userName" optionValue="userName"
/g:select

<br />

<div class="buttons">

<span class="button"><g:actionSubmit value="Login" />

</span>

</div>

</form>

</div>

</body>
 </html>

