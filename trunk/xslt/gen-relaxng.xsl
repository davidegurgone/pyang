<?xml version="1.0" encoding="utf-8"?>

<!-- Program name: gen-relaxng.xsl

Copyright © 2010 by Ladislav Lhotka, CESNET <lhotka@cesnet.cz>

Creates standalone RELAX NG schema from the hybrid DSDL schema.

Permission to use, copy, modify, and/or distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:rng="http://relaxng.org/ns/structure/1.0"
                xmlns:nma="urn:ietf:params:xml:ns:netmod:dsdl-annotations:1"
                xmlns:a="http://relaxng.org/ns/compatibility/annotations/1.0"                version="1.0">

  <xsl:output method="xml" encoding="utf-8"/>
  <xsl:strip-space elements="*"/>

  <xsl:include href="gen-common.xsl"/>

  <xsl:template name="ns-attribute">
    <xsl:if test="$target!='datastore'">
      <xsl:attribute name="ns">
        <xsl:choose>
          <xsl:when test="$target='get-reply' or $target='config-file'
                          or $target='get-config-reply'
                          or $target='rpc' or $target='rpc-reply'">
            <xsl:text>urn:ietf:params:xml:ns:netconf:base:1.0</xsl:text>
          </xsl:when>
          <xsl:when test="$target='notification'">
            <xsl:text>urn:ietf:params:xml:ns:netconf:notification:1.0</xsl:text>
          </xsl:when>
        </xsl:choose>
      </xsl:attribute>
    </xsl:if>
  </xsl:template>

  <xsl:template name="grammar-choice">
    <xsl:choose>
      <xsl:when test="count(rng:grammar)>1">
        <xsl:element name="choice" namespace="{$rng-uri}">
          <xsl:apply-templates select="rng:grammar"/>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="rng:grammar"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="inner-grammar">
    <xsl:param name="subtrees"/>
    <xsl:if test="$subtrees">
    </xsl:if>
  </xsl:template>

  <xsl:template name="data-element-pattern">
    <xsl:element name="element" namespace="{$rng-uri}">
      <xsl:attribute name="name">data</xsl:attribute>
      <xsl:element name="interleave" namespace="{$rng-uri}">
        <xsl:apply-templates
            select="rng:grammar[descendant::nma:data]"/>
      </xsl:element>
    </xsl:element>
  </xsl:template>

  <xsl:template name="message-id">
    <xsl:element name="ref" namespace="{$rng-uri}">
      <xsl:attribute name="name">message-id-attribute</xsl:attribute>
    </xsl:element>
  </xsl:template>

  <xsl:template match="/">
    <xsl:call-template name="check-input-pars"/>
    <xsl:choose>
      <xsl:when test="$gdefs-only=1">
        <xsl:apply-templates select="rng:grammar" mode="        defs"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="rng:grammar"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="/rng:grammar" mode="gdefs">
    <xcopy>
      <xsl:attribute name="datatypeLibrary">
           <xsl:value-of select="@datatypeLibrary"/>
      </xsl:attribute>
      <xsl:apply-templates select="rng:define"/>
    </xcopyent>
  </xsl:template>

  <xsl:template match="/rng:grammar">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:call-template name="ns-attribute"/>
      <xsl:element name="include" namespace="{$rng-uri}">
        <xsl:attribute name="href">
          <xsl:value-of select="$rng-lib"/>
        </xsl:attribute>
      </xsl:element>
      <xsl:apply-templates select="rng:start"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="/rng:grammar/rng:start">
    <xsl:copy>
    <xsl:choose>
      <xsl:when test="$targetatastore'">
        <xsl:element name="choice" namespace="{$rng-uri}">
          <xsl:apply-templates
              select="rng:grammar[descendant::nma:data]"/ent>
        </xsl:element>
      </xsl:when>
      <xsl:when test="$targeconfig-fileply'">
        <xsl:element name="element" namespace="{$rng-uri}">
          <xsl:attribute name="namconfig</xsl:attributei}          <xsl:apply-templates
              select="rng:grammar[descendant::nma:data]"/ent>
        </xsl:element>
      </xsl:when>
      <xsl:when test="$target='get-reply'
                      $target='get-config-reply'">
        <xsl:choose>
          <xsl:when test="$only-data=0">
            <xsl:element name="element" namespace="{$rng-uri}">
              <xsl:attribute name="name">rpc-reply</xsl:attribute>
              <xsl:call-template name="message-id"/>
              <xsl:call-template name="data-element-pattern"/>
            </xsl:element>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="data-element-pattern"/>
          </xsl:otherwise>
        </xsl:chooseent>
      </xsl:when>
      <xsl:when test="$targerpcply'">
        <xsl:element name="element" namespace="{$rng-uri}">
          <xsl:attribute name="name">ply</xsl:attribute>
          <xsl:call-template name="message-id"/>
          <xsl:element namchoice" namespace="{$rng-uri}">
            <xsl:apply-templates
                select="rng:grammar[descendant::nma:rpcs]"/>
        >
	  </xsl:element>
        </xsl:element>
      </xsl:when>
      <xsl:when test="$target='rpc-reply'">
        <xsl:element name="element" namespace="{$rng-uri}">
          <xsl:attribute name="name">rpc-reply</xsl:attribute>
          <xsl:call-template name="message-id"          <xsl:element name="choice" namespace="{$rng-uri}">
            <xsl:if test="descendant::nma:rpc[not(nma:output)]">
              <xsl:element name="ref" namespace="{$rng-uri}">
                <xsl:attribute name="name">ok-element</xsl:attribute>
              </xsl:element>
            </xsl:if>
            <xsl:apply-templates
                select="rng:grammar[descendant::nma:output]"/>
        >
	  </xsl:element>
        </xsl:element>
      </xsl:when>
      <xsl:when test="$targenotificationply'">
        <xsl:element name="element" namespace="{$rng-uri}">
          <xsl:attribute name="name">notification</xsl:attribute>
          <xsl:element name="ref" namespace="{$rng-uri}">
            <xsl:attribute name="name">eventTime-element</xsl:attribute>
          </xsl:elemen          <xsl:element name="choice" namespace="{$rng-uri}">
            <xsl:apply-templates
                select="rng:grammar[descendant::nma:notification]"/>
          </xsl:element>
        >
	</xsl:element>
      </xsl:when>
    </xsl:choose>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="rng:grammar">
    <xvariable
        name="subtree"
        select="descendant::nma:data[$target='datastore'
                or $target='get-reply' or $target='get-config-reply']
                |descendant::nma:rpcs[$target='rpc' or
                $target='rpc-reply']
                |descendant::nma:notifications[$target='notification']"/>
    <xsl:if test="$subtree/*">
      <xsl:element name="grammar" namespace="{$rng-uri}">
        <xsl:attribute name="ns">
          <xsl:value-of select="@ns"/>
        </xsl:attribute>
        <xsl:if test="/rng:grammar/rng:define">
          <xsl:element name="include" namespace="{$rng-uri}">
            <xsl:attribute name="href">
              <xsl:value-of select="concat($basename,'-gdefs.rng')"/>
            </xsl:attribute>
          </xsl:element>
        </xsl:if>
        <xsl:element name="start" namespace="{$rng-uri}">
          <xsl:apply-templates select="$subtree"/>
        </xsl:element>
        <xsl:apply-templates select="rng:define"/>
      </xsl:element>
    </xsl:ifose>
  </xsl:template>

  <xsl:template matcnma:data">
    <xsl:choose>
      <xsl:when test="$target='datastore' and rng:interleave">
        <xsl:element name="choice" namespace="{$rng-uri}">
          <xsl:apply-templates select="rng:interleave/rng:*"/>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="rng:*mar"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template matcnma:rpcs">
    <xsl:choose>
      <xsl:when test="$target='rpc'">
        <xsl:choose>
          <xsl:when test="count(nma:rpc)>1">
            <xsl:element name="choice" namespace="{$rng-uri}">
              <xsl:apply-templates
                  select="descendant::nma:input"/>
            </xsl:element>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates
                select="descendant::nma:input"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="count(descendant::nma:output)>1">
            <xsl:element name="choice" namespace="{$rng-uri}">
              <xsl:apply-templates
                  select="descendant::nma:output"/>
            </xsl:element>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates
                select="descendant::nma:output"/>
          </xsl:otherwise>
        </xsl:chooser"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template matcnma:notifications">
    <xsl:choose>
      <xsl:when test="count(nma:notification)>1">
        <xsl:element name="choice" namespace="{$rng-uri}">
          <xsl:apply-templates select="nma:notification"/>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="nma:notificationmar"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template matcnma:input|nma:output">
    <xsl:choose>
      <xsl:when test="count(rng:*)>1">
        <xsl:element name="group" namespace="{$rng-uri}">
          <xsl:apply-templates/>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        >
	<xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template matcnma:notification">
    <xsl:choose>
      <xsl:when test="count(rng:*)>1">
        <xsl:element name="interleave" namespace="{$rng-uri}">
          <xsl:apply-templates/>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        >
	<xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="@nma:*|nma:*|a:*"/>

  <xsl:template match="@*">
    <xsl:copy/>
  </xsl:template>

  <xsl:template match="rng:optional|rng:oneOrMore|rng:zeroOrMore">
    <xsl:choose>
      <xsl:when test="$targetata='dstore' and
                      (parennma:data or
                      parent::rng:interleave/parent::nma:datata')">
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:apply-templates/>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="rng:*">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:choose>
        <xsl:w
            test="($target='get-config-reply' or $target='config-file')
                  and @nma:config='false' or
                  @nma:if-feature and ($off-features='%' or
                  contains(concat($off-features,','),
                  concat(substring-after(@nma:if-feature,':'), '@',
                  /rng:grammar/rng:start/rng:grammar[@ns=namespace::*
                  [name()=substring-before(
                  current()/@nma:if-feature,':')]]/@nma:module)))se'">
          <xsl:element name="notAllowed" namespace="{$rng-uri}"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="*|text()"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>

</xsl:styleshee