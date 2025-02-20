<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:gco="http://standards.iso.org/iso/19115/-3/gco/1.0"
                xmlns:cit="http://standards.iso.org/iso/19115/-3/cit/2.0"
                xmlns:mdb="http://standards.iso.org/iso/19115/-3/mdb/2.0"
                xmlns:lan="http://standards.iso.org/iso/19115/-3/lan/1.0"
                exclude-result-prefixes="#all">


  <!-- Convert an element gco:CharacterString
  to the GN localized string structure -->
  <xsl:template mode="get-iso19115-3.2018-localized-string" match="*">
    <xsl:param name="defaultLanguage" select="'eng'" as="xs:string?"/>

    <xsl:variable name="mainLanguage"
                  select="ancestor::mdb:MD_Metadata/mdb:defaultLocale/*/lan:language/*/@codeListValue"/>

    <xsl:for-each select="gco:CharacterString|
                          lan:PT_FreeText/*/lan:LocalisedCharacterString">
      <xsl:variable name="localeId"
                    select="substring-after(@locale, '#')"/>
      <value lang="{if (@locale)
                    then ancestor::mdb:MD_Metadata/mdb:otherLocale/*[@id = $localeId]/lan:language/*/@codeListValue
                    else if ($mainLanguage)
                    then $mainLanguage
                    else $defaultLanguage}">
        <xsl:value-of select="."/>
      </value>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="collect-distribution-links">

    <xsl:for-each select="*/descendant::*[
                            local-name() = 'onLine'
                            ]/*[cit:linkage/gco:CharacterString != '']">
      <item>
        <id>
          <xsl:value-of select="cit:linkage/gco:CharacterString"/>
        </id>
        <title>
          <xsl:apply-templates mode="get-iso19115-3.2018-localized-string"
                               select="cit:name"/>
        </title>
        <url>
          <xsl:apply-templates mode="get-iso19115-3.2018-localized-string"
                               select="cit:linkage"/>
        </url>
        <function>
          <xsl:value-of select="cit:function/*/@codeListValue"/>
        </function>
        <applicationProfile>
          <xsl:value-of select="cit:applicationProfile/gco:CharacterString"/>
        </applicationProfile>
        <description>
          <xsl:apply-templates mode="get-iso19115-3.2018-localized-string"
                               select="cit:description"/>
        </description>
        <protocol>
          <xsl:value-of select="cit:protocol/gco:CharacterString"/>
        </protocol>
        <type>onlinesrc</type>
      </item>
    </xsl:for-each>
  </xsl:template>


  <xsl:variable name="documentsConfig" as="node()*">
    <doc protocol="WWW:LINK" function="legend">
      <element>portrayalCatalogueCitation</element>
    </doc>
    <doc protocol="WWW:LINK" function="featureCatalogue">
      <element>featureCatalogueCitation</element>
    </doc>
    <doc protocol="WWW:LINK" function="dataQualityReport">
      <element>additionalDocumentation</element>
      <element>specification</element>
      <element>reportReference</element>
    </doc>
  </xsl:variable>

  <xsl:template name="collect-documents">
    <xsl:variable name="root" select="."/>

    <xsl:for-each select="$documentsConfig">
      <xsl:variable name="docType"
                    select="current()"/>
      <xsl:for-each select="$root/descendant::*[
                              local-name() = $docType/element/text()
                              ]/*[cit:onlineResource/*/cit:linkage/gco:CharacterString != '']">
        <item>
          <id>
            <xsl:value-of select="cit:onlineResource/cit:CI_OnlineResource/cit:linkage/gco:CharacterString"/>
          </id>
          <url>
            <xsl:apply-templates mode="get-iso19115-3.2018-localized-string"
                                 select="cit:onlineResource/*/cit:linkage"/>
          </url>
          <title>
            <xsl:apply-templates mode="get-iso19115-3.2018-localized-string"
                                 select="cit:title"/>
          </title>
          <description>
            <xsl:apply-templates mode="get-iso19115-3.2018-localized-string"
                                 select="cit:onlineResource/*/cit:description"/>
          </description>
          <protocol><xsl:value-of select="$docType/@protocol"/></protocol>
          <function><xsl:value-of select="$docType/@function"/></function>
          <type>onlinesrc</type>
        </item>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>
