<?xml version="1.0" encoding="utf-8"?>

<!-- Program name: gen-common.xsl

Copyright © 2010 by Ladislav Lhotka, CESNET <lhotka@cesnet.cz>

Common templates for schema-generating stylesheets.

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
                version="1.0">

  <!-- Command line parameters -->
  <!-- Validation target: one of "dstore", "get-reply", "getconf-reply",
       "rpc", "rpc-reply", "notif" -->
  <xsl:param name="target">dstore</xsl:param>
  <!-- Full path of the RELAX NG library file -->
  <xsl:param name="rng-lib">relaxng-lib.rng</xsl:param>
  <!-- Output of RELAX NG global defs only? -->
  <xsl:param name="gdefs-only" select="0"/>
  <!-- Base name of the output schemas -->
  <xsl:param name="basename">
    <xsl:for-each
        select="//rng:grammar/@nma:module">
      <xsl:value-of select="."/>
      <xsl:if test="position()!=last()">
        <xsl:text>_</xsl:text>
      </xsl:if>
    </xsl:for-each>
  </xsl:param>

  <!-- Namespace URIs -->
  <xsl:param name="rng-uri">http://relaxng.org/ns/structure/1.0</xsl:param>
  <xsl:param
      name="dtdc-uri">http://relaxng.org/ns/compatibility/annotations/1.0</xsl:param>
  <xsl:param name="dc-uri">http://purl.org/dc/terms</xsl:param>
  <xsl:param
      name="nma-uri">urn:ietf:params:xml:ns:netmod:dsdl-annotations:1</xsl:param>
  <xsl:param name="nc-uri">urn:ietf:params:xml:ns:netconf:base:1.0</xsl:param>
  <xsl:param name="en-uri">urn:ietf:params:xml:ns:netconf:notification:1.0</xsl:param>

  <xsl:variable name="netconf-part">
    <xsl:choose>
      <xsl:when
          test="$target='get-reply' or
                $target='getconf-reply'">/nc:rpc-reply/nc:data</xsl:when>
      <xsl:when test="$target='rpc'">/nc:rpc</xsl:when>
      <xsl:when test="$target='rpc-reply'">/nc:rpc-reply</xsl:when>
      <xsl:when test="$target='notif'">/en:notification</xsl:when>
    </xsl:choose>
  </xsl:variable>

  <xsl:template name="check-input-pars">
    <xsl:if test="not($target='get-reply' or $target='dstore' or $target='rpc'
                  or $target='rpc-reply' or $target='getconf-reply'
                  or $target='notif')">
      <xsl:message terminate="yes">
        <xsl:text>Bad 'target' parameter: </xsl:text>
        <xsl:value-of select="$target"/>
      </xsl:message>
    </xsl:if>
    <xsl:if test="($target='dstore' or starts-with($target,'get')) and
                  not(//nma:data/rng:*)">
      <xsl:message terminate="yes">
        <xsl:text>Data model defines no data.</xsl:text>
      </xsl:message>
    </xsl:if>
    <xsl:if test="($target='rpc' or $target='rpc-reply') and
                  not(//nma:rpc)">
      <xsl:message terminate="yes">
        <xsl:text>Data model defines no RPC methods.</xsl:text>
      </xsl:message>
    </xsl:if>
    <xsl:if test="$target='notif' and not(//nma:notification)">
      <xsl:message terminate="yes">
        <xsl:text>Data model defines no notifications.</xsl:text>
      </xsl:message>
    </xsl:if>
    <xsl:if test="not($gdefs-only='0' or $gdefs-only='1')">
      <xsl:message terminate="yes">
        <xsl:text>Bad 'gdefs-only' parameter value: </xsl:text>
        <xsl:value-of select="$gdefs-only"/>
      </xsl:message>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
