<?xml version="1.0" ?>

<!DOCTYPE foo [
    <!ENTITY lt "&#060;">
    <!ENTITY gt "&#062;">
]>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
 
 <!-- document tag -->
 
 <xsl:template match="/document">
  
  <html>
   <head>
    
    <title><xsl:value-of select="title"/></title>
    
    <meta name="description">
     <xsl:attribute name="content">
      <xsl:value-of select="meta/description"/>
     </xsl:attribute>
    </meta>
    
    <meta name="keywords">
     <xsl:attribute name="content">
      <xsl:value-of select="meta/keywords"/>
     </xsl:attribute>
    </meta>
    
    <meta name="author">
     <xsl:attribute name="content"><xsl:value-of select="author/name"/> (<xsl:value-of select="author/email"/>)</xsl:attribute>
    </meta>
    
    <meta name="date">
     <xsl:attribute name="content">
      <xsl:value-of select="date"/>
     </xsl:attribute>
    </meta>
    
   </head>
   <body bgcolor="#ffffff">
    <div style="margin-left: 5%; width: 90%;">
    <center>
     <h1>
      <xsl:value-of select="title"/>
     </h1>
     <p>
      by <xsl:value-of select="author/name"/> 
       &lt;<a>
        <xsl:attribute name="href">mailto:<xsl:value-of select="author/email"/>
        </xsl:attribute><xsl:value-of select="author/email"/></a>&gt;
     </p>
    </center>
    <xsl:apply-templates select="content"/>
    </div>
   </body>
  </html>
 </xsl:template>
 
 <!-- section tag -->
 <xsl:template match="section">
  <xsl:variable name="level"><xsl:value-of select="count(ancestor::section)+1"/></xsl:variable>
  <xsl:variable name="number"><xsl:number level="multiple" count="section" format="1.1.1"/></xsl:variable>
  <a>
   <xsl:attribute name="name">sec<xsl:value-of select="$number"/></xsl:attribute>
  </a>
  <xsl:choose>
   <xsl:when test="$level=1">
    <h2><xsl:value-of select="$number"/><xsl:text> </xsl:text> 
        <xsl:value-of select="@heading"/></h2>
   </xsl:when>
   <xsl:when test="$level=2">
    <h3><xsl:value-of select="$number"/><xsl:text> </xsl:text> 
        <xsl:value-of select="@heading"/></h3>
   </xsl:when>
   <xsl:when test="$level=3">
    <h4><xsl:value-of select="$number"/><xsl:text> </xsl:text> 
        <xsl:value-of select="@heading"/></h4>
   </xsl:when>
   <xsl:when test="$level=4">
    <h5><xsl:value-of select="$number"/><xsl:text> </xsl:text> 
        <xsl:value-of select="@heading"/></h5>
   </xsl:when>
   <xsl:otherwise>
    <h5><xsl:value-of select="$number"/><xsl:text> </xsl:text> 
        <xsl:value-of select="@heading"/></h5>
   </xsl:otherwise>
  </xsl:choose>
  <xsl:apply-templates />
 </xsl:template>
 
 <!-- paragraph tag -->
 <xsl:template match="paragraph">
  <p style="text-indent: 10pt; text-align: justify;"> 
   <xsl:apply-templates/>
  </p>
 </xsl:template>
 
 <!-- link tag -->
 <xsl:template match="link">
  <a>
   <xsl:attribute name="href"><xsl:value-of select="@href"/></xsl:attribute>
   <xsl:value-of select="."/>
  </a>
 </xsl:template>
 
 <!-- code tag -->
 <xsl:template match="code">
  <code><xsl:value-of select="."/></code>
 </xsl:template>
 
 <!-- codeblock -->
 <xsl:template match="codeblock">
  <div style="margin-bottom: 10pt; background-color: #ffffbb; padding: 5pt; border: 1px; border-style: solid;">
   <pre style="margin: 0pt;"><xsl:value-of select="."/></pre>
  </div>
 </xsl:template>
 
 <!-- image tag -->
 <xsl:template match="image">
  <p style="text-align: center;"><code>[Image: <xsl:value-of select="@href"/>]</code></p>
 </xsl:template>
 
 <xsl:template match="table">
  <table width="100%" cellspacing="3" cellpadding="3" border="0">
   <xsl:apply-templates select="table-row"/>
  </table>
 </xsl:template>
 
 <xsl:template match="table-row">
  <tr>
   <xsl:choose>
    <xsl:when test="position() mod 2 = 1">
     <xsl:attribute name="bgcolor">#ddddff</xsl:attribute>
    </xsl:when>
    <xsl:otherwise>
     <xsl:attribute name="bgcolor">#ffffff</xsl:attribute>
    </xsl:otherwise>
   </xsl:choose>
   <xsl:apply-templates select="table-cell"/>
  </tr>
 </xsl:template>
   
 <xsl:template match="table-cell">
  <td valign="top" align="left">
   <xsl:apply-templates/>
  </td>
 </xsl:template>
 
 <xsl:template match="bold">
  <strong><xsl:apply-templates/></strong>
 </xsl:template>
 
 <xsl:template match="example">
  <p style="margin-top: 5pt">
   <strong>Example:</strong>
  </p>
  <p style="margin-left: 20pt; margin-right: 20pt">
   <xsl:apply-templates/>
  </p>
 </xsl:template>
 
 <xsl:template match="nl">
  <br/>
 </xsl:template>
 
 <!-- toc tag -->
 
 <xsl:template match="toc">
  <h2>Table of Content</h2>
  <xsl:for-each select="..//section">
   <xsl:variable name="level"><xsl:value-of select="count(ancestor::section)+1"/></xsl:variable>
   <xsl:variable name="number"><xsl:number level="multiple" count="section" format="1.1.1"/></xsl:variable>
  
   <xsl:choose>
    <xsl:when test="$level=1">
     <p style="margin: 0pt; margin-left: 10pt">
      <a>
       <xsl:attribute name="href">#sec<xsl:value-of select="$number"/></xsl:attribute>
       <strong>
        <xsl:value-of select="$number"/><xsl:text> </xsl:text>
        <xsl:value-of select="@heading"/>
       </strong>
      </a>
     </p>
    </xsl:when>
    <xsl:when test="$level=2">
     <p style="margin: 0pt; margin-left: 20pt">
      <a>
       <xsl:attribute name="href">#sec<xsl:value-of select="$number"/></xsl:attribute>
       <strong>
        <xsl:value-of select="$number"/><xsl:text> </xsl:text>
        <xsl:value-of select="@heading"/>
       </strong>
      </a>
     </p>
    </xsl:when>
    <xsl:when test="$level=3">
     <p style="margin: 0pt; margin-left: 30pt;">
      <a>
       <xsl:attribute name="href">#sec<xsl:value-of select="$number"/></xsl:attribute>
       <xsl:value-of select="$number"/><xsl:text> </xsl:text>
       <xsl:value-of select="@heading"/>
      </a>
     </p>
    </xsl:when>
    <xsl:when test="$level=4">
     <p style="margin: 0pt; margin-left: 40pt;">
      <a>
       <xsl:attribute name="href">#sec<xsl:value-of select="$number"/></xsl:attribute>
       <xsl:value-of select="$number"/><xsl:text> </xsl:text>
       <xsl:value-of select="@heading"/>
      </a>
     </p>
    </xsl:when>
    <xsl:otherwise>
     <p style="margin: 0pt; margin-left: 40pt;">
      <a>
       <xsl:attribute name="href">#sec<xsl:value-of select="$number"/></xsl:attribute>
       <xsl:value-of select="$number"/><xsl:text> </xsl:text>
       <xsl:value-of select="@heading"/>
      </a>
     </p>
    </xsl:otherwise>
   </xsl:choose>
  </xsl:for-each>
 </xsl:template>
  

</xsl:stylesheet>
