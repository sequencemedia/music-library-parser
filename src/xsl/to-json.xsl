<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:j="http://www.w3.org/2013/XSLT/xml-to-json"
	exclude-result-prefixes="xsl xs j">
	<xsl:output encoding="UTF-8" method="text" omit-xml-declaration="yes" indent="no" />
	<xsl:template match="integer">
		<xsl:value-of select="text()" />
	</xsl:template>

	<xsl:template match="true | false">
		<xsl:value-of select="lower-case(local-name(.))" />
	</xsl:template>

	<xsl:template match="string">
		<xsl:text>"</xsl:text>
		<xsl:value-of select="j:escape(.)" />
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

	<!-- Escape special characters -->
	<xsl:function name="j:escape" as="xs:string" visibility="final">
		<xsl:param name="s" as="xs:string" />
		<xsl:value-of>
			<xsl:for-each select="string-to-codepoints($s)">
				<xsl:choose>
					<xsl:when test=". gt 65535">
						<xsl:value-of select="concat('\u', j:to-hex((. - 65536) idiv 1024 + 55296))" />
						<xsl:value-of select="concat('\u', j:to-hex((. - 65536) mod 1024 + 56320))" />
					</xsl:when>
					<xsl:when test=". = 34">\"</xsl:when>
					<xsl:when test=". = 92">\\</xsl:when>
					<xsl:when test=". = 08">\b</xsl:when>
					<xsl:when test=". = 09">\t</xsl:when>
					<xsl:when test=". = 10">\n</xsl:when>
					<xsl:when test=". = 12">\f</xsl:when>
					<xsl:when test=". = 13">\r</xsl:when>
					<xsl:when test=". lt 32 or (. ge 127 and . le 160)">
						<xsl:value-of select="concat('\u', j:to-hex(.))" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="codepoints-to-string(.)" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
		</xsl:value-of>
	</xsl:function>

	<!-- Convert a UTF16 codepoint to a string of hex characters -->
	<xsl:function name="j:to-hex" as="xs:string" visibility="final">
		<xsl:param name="i" as="xs:integer" />
		<xsl:variable name="h" select="'0123456789abcdef'" />
		<xsl:value-of>
			<xsl:value-of select="substring($h, $i idiv 4096 + 1, 1)" />
			<xsl:value-of select="substring($h, $i idiv 256 mod 16 + 1, 1)" />
			<xsl:value-of select="substring($h, $i idiv 16 mod 16 + 1, 1)" />
			<xsl:value-of select="substring($h, $i mod 16 + 1, 1)" />
		</xsl:value-of>
	</xsl:function>
</xsl:stylesheet>
