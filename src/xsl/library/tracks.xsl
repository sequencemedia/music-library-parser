<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:seq="http://sequencemedia.net"
	xmlns:url-decoder="java:java.net.URLDecoder"
	exclude-result-prefixes="xsl seq url-decoder">
	<xsl:output encoding="UTF-8" method="text" omit-xml-declaration="yes" indent="no" />

	<xsl:param name="destination" />

	<xsl:variable name="tracks" select="/plist/dict/key[. = 'Tracks']/following-sibling::dict" />

	<!-- https://en.wikipedia.org/wiki/Combining_character -->
	<xsl:function name="seq:remove-combining-characters">
		<xsl:param name="s" />

		<xsl:value-of
			select="
				translate(translate(translate(translate(translate(translate(translate($s,
					'&#x0300;&#x301;&#x0302;&#x0303;&#x0304;&#x0305;&#x306;&#x0307;&#x0308;&#x0309;&#x030A;&#x030B;&#x030C;&#x030D;&#x030E;&#x030F;', ''),
					'&#x0310;&#x311;&#x0312;&#x0313;&#x0314;&#x0315;&#x316;&#x0317;&#x0318;&#x0319;&#x031A;&#x031B;&#x031C;&#x031D;&#x031E;&#x031F;', ''),
					'&#x0320;&#x321;&#x0322;&#x0323;&#x0324;&#x0325;&#x326;&#x0327;&#x0328;&#x0329;&#x032A;&#x032B;&#x032C;&#x032D;&#x032E;&#x032F;', ''),
					'&#x0330;&#x331;&#x0332;&#x0333;&#x0334;&#x0335;&#x336;&#x0337;&#x0338;&#x0339;&#x033A;&#x033B;&#x033C;&#x033D;&#x033E;&#x033F;', ''),
					'&#x0340;&#x341;&#x0342;&#x0343;&#x0344;&#x0345;&#x346;&#x0347;&#x0348;&#x0349;&#x034A;&#x034B;&#x034C;&#x034D;&#x034E;&#x034F;', ''),
					'&#x0350;&#x351;&#x0352;&#x0353;&#x0354;&#x0355;&#x356;&#x0357;&#x0358;&#x0359;&#x035A;&#x035B;&#x035C;&#x035D;&#x035E;&#x035F;', ''),
					'&#x0360;&#x361;&#x0362;&#x0363;&#x0364;&#x0365;&#x366;&#x0367;&#x0368;&#x0369;&#x036A;&#x036B;&#x036C;&#x036D;&#x036E;&#x036F;', '')"
		/>
	</xsl:function>

	<xsl:function name="seq:normalize-for-path">
		<xsl:param name="s" />

		<xsl:value-of
			select="normalize-space(seq:remove-combining-characters(translate(replace(normalize-unicode($s, 'NFD'), '[%\[\]*?]', '_'), '\/:', '___')))"
		/>
	</xsl:function>

	<xsl:function name="seq:get-href-for-album">
		<xsl:param name="albumArtist" />
		<xsl:param name="album" />

		<xsl:variable name="filePath" select="seq:normalize-for-path($albumArtist)" />
		<xsl:variable name="fileName" select="seq:normalize-for-path($album)" />

		<xsl:choose>
			<xsl:when test="$destination">
				<xsl:value-of select="$destination" />
				<xsl:text>/Tracks/</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>Music Library/Tracks/</xsl:text>
			</xsl:otherwise>
		</xsl:choose>

		<xsl:value-of select="$filePath" />
		<xsl:text>/</xsl:text>
		<xsl:value-of select="$fileName" />
		<xsl:text>.m3u8</xsl:text>
	</xsl:function>

	<xsl:function name="seq:get-href-for-album">
		<xsl:param name="album" />

		<xsl:variable name="fileName" select="seq:normalize-for-path($album)" />

		<xsl:choose>
			<xsl:when test="$destination">
				<xsl:value-of select="$destination" />
				<xsl:text>/Tracks/Compilations/</xsl:text>
			</xsl:when>

			<xsl:otherwise>
				<xsl:text>Music Library/Tracks/Compilations/</xsl:text>
			</xsl:otherwise>
		</xsl:choose>

		<xsl:value-of select="$fileName" />
		<xsl:text>.m3u8</xsl:text>
	</xsl:function>

	<xsl:template match="key[. = 'Tracks']">
		<!-- Albums: 'Album Artist' -->
		<xsl:for-each-group
			group-by="key[. = 'Album Artist']/following-sibling::*[1]/text()"
			select="following-sibling::dict[1]/dict[
				key[. = 'Album Artist']/following-sibling::*[1]/text() and
				key[. = 'Track Type']/following-sibling::*[1]/text() eq 'File' and
				key[. = 'Album'] and
				contains(lower-case(key[. = 'Kind']/following-sibling::*[1]/text()), 'audio') and
				not(local-name(key[. = 'Podcast']/following-sibling::*[1]) eq 'true') and
				(
					not(key[. = 'Compilation']) or not(local-name(key[. = 'Compilation']/following-sibling::*[1]) eq 'true')
				)
			]">
			<xsl:variable name="albumArtist" select="current-grouping-key()" />

			<xsl:for-each-group group-by="key[. = 'Album']/following-sibling::*[1]/text()" select="current-group()">
				<xsl:result-document href="{seq:get-href-for-album($albumArtist, current-grouping-key())}" method="text">
					<xsl:call-template name="album">
						<xsl:with-param name="current-group" select="current-group()" />
					</xsl:call-template>
				</xsl:result-document>
			</xsl:for-each-group>
		</xsl:for-each-group>

		<!-- Albums: 'Artist' not 'Album Artist' -->
		<xsl:for-each-group
			group-by="key[. = 'Artist']/following-sibling::*[1]/text()"
			select="following-sibling::dict[1]/dict[
				(
					not(key[. = 'Album Artist']/following-sibling::*[1]/text())
				) and
				key[. = 'Track Type']/following-sibling::*[1]/text() eq 'File' and
				key[. = 'Album'] and
				contains(lower-case(key[. = 'Kind']/following-sibling::*[1]/text()), 'audio') and
				not(local-name(key[. = 'Podcast']/following-sibling::*[1]) eq 'true') and
				(
					not(key[. = 'Compilation']) or not(local-name(key[. = 'Compilation']/following-sibling::*[1]) eq 'true')
				)
			]">
			<xsl:variable name="artist" select="current-grouping-key()" />

			<xsl:for-each-group group-by="key[. = 'Album']/following-sibling::*[1]/text()" select="current-group()">
				<xsl:result-document href="{seq:get-href-for-album($artist, current-grouping-key())}" method="text">
					<xsl:call-template name="album">
						<xsl:with-param name="current-group" select="current-group()" />
					</xsl:call-template>
				</xsl:result-document>
			</xsl:for-each-group>
		</xsl:for-each-group>

		<!-- Compilation albums -->
		<xsl:for-each-group
			group-by="key[. = 'Album']/following-sibling::*[1]/text()"
			select="following-sibling::dict[1]/dict[
				key[. = 'Track Type']/following-sibling::*[1]/text() eq 'File' and
				key[. = 'Album'] and
				contains(lower-case(key[. = 'Kind']/following-sibling::*[1]/text()), 'audio') and
				not(local-name(key[. = 'Podcast']/following-sibling::*[1]) eq 'true') and
				(
					key[. = 'Compilation'] and local-name(key[. = 'Compilation']/following-sibling::*[1]) eq 'true'
				)
			]">
			<xsl:result-document href="{seq:get-href-for-album(current-grouping-key())}" method="text">
				<xsl:call-template name="album">
					<xsl:with-param name="current-group" select="current-group()" />
				</xsl:call-template>
			</xsl:result-document>
		</xsl:for-each-group>
	</xsl:template>

	<!-- Album: #EXTM3U -->
	<xsl:template name="album">
		<xsl:param name="current-group" />

		<xsl:text>#EXTM3U</xsl:text>
		<xsl:text>&#13;</xsl:text>

		<xsl:for-each select="$current-group">
			<xsl:sort select="number(key[. = 'Disc Number']/following-sibling::*[1]/text())" />
			<xsl:sort select="number(key[. = 'Track Number']/following-sibling::*[1]/text())" />

			<xsl:apply-templates mode="album-track" select="." />
		</xsl:for-each>
	</xsl:template>

	<!-- Album track: #EXTINF -->
	<xsl:template mode="album-track" match="dict">
		<xsl:variable name="totalTime" select="floor(number(key[. = 'Total Time']/following-sibling::*[1]/text()) div 1000)" />
		<xsl:variable name="location" select="url-decoder:decode(replace(key[. = 'Location']/following-sibling::*[1]/text(), '[&#43;]', '%2b'))" />

		<xsl:text>#EXTINF:</xsl:text>
		<xsl:choose>
			<xsl:when test="number($totalTime)">
				<xsl:value-of select="$totalTime" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>-1</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>,</xsl:text>
		<xsl:value-of select="normalize-space(key[. = 'Name']/following-sibling::*[1]/text())" />
		<xsl:text>&#32;-&#32;</xsl:text>
		<xsl:value-of select="normalize-space(key[. = 'Artist']/following-sibling::*[1]/text())" />
		<xsl:text>&#13;</xsl:text>

		<xsl:choose>
			<xsl:when test="starts-with($location, 'file://')">
				<xsl:value-of select="substring($location, 8)" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$location" />
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>&#13;</xsl:text>
	</xsl:template>

	<xsl:template match="/">
		<xsl:apply-templates select="plist/dict/key[. = 'Tracks']" />
	</xsl:template>
</xsl:stylesheet>
