<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	exclude-result-prefixes="xsl">
	<xsl:output encoding="UTF-8" method="text" omit-xml-declaration="yes" indent="no" />
	<xsl:template match="integer">
		<xsl:value-of select="text()" />
	</xsl:template>

	<xsl:template match="true | false">
		<xsl:value-of select="lower-case(local-name(.))" />
	</xsl:template>

	<xsl:template match="string">
		<xsl:text>"</xsl:text>
		<xsl:value-of select="replace(text(), '&quot;', '\\&quot;')" />
		<xsl:text>"</xsl:text>
	</xsl:template>

	<xsl:template match="date">
		<xsl:text>"</xsl:text>
		<xsl:value-of select="text()" />
		<xsl:text>"</xsl:text>
	</xsl:template>

	<xsl:template match="data">
		<xsl:text>[</xsl:text>
		<xsl:variable name="data" select="replace(replace(text(), '&#9;', ''), '^&#10;|&#10;$', '')" />
		<xsl:for-each select="tokenize($data, '&#10;')">
			<xsl:text>"</xsl:text>
			<xsl:sequence select="." />
			<xsl:text>"</xsl:text>
			<xsl:if test="position() ne last()">
				<xsl:text>,</xsl:text>
			</xsl:if>
		</xsl:for-each>
		<xsl:text>]</xsl:text>
	</xsl:template>

	<xsl:template match="key">
		<xsl:text>"</xsl:text>
		<xsl:value-of select="text()" />
		<xsl:text>":</xsl:text>
		<xsl:apply-templates select="following-sibling::*[1]" />
		<xsl:if test="position() ne last()">
			<xsl:text>,</xsl:text>
		</xsl:if>
	</xsl:template>

	<xsl:template match="dict">
		<xsl:text>{</xsl:text>
		<xsl:apply-templates select="key" />
		<xsl:text>}</xsl:text>
		<xsl:if test="position() ne last()">
			<xsl:text>,</xsl:text>
		</xsl:if>
	</xsl:template>

	<xsl:template match="array">
		<xsl:text>[</xsl:text>
		<xsl:apply-templates select="dict" />
		<xsl:text>]</xsl:text>
		<xsl:if test="position() ne last()">
			<xsl:text>,</xsl:text>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>
