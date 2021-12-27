<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:seq="http://sequencemedia.net"
	xmlns:url-decoder="java:java.net.URLDecoder"
	exclude-result-prefixes="xsl seq url-decoder">
	<xsl:output encoding="UTF-8" method="text" omit-xml-declaration="yes" indent="no" />

	<xsl:param name="destination" />

	<xsl:variable name="tracks" select="/plist/dict/key[. = 'Tracks']/following-sibling::dict" />
	<xsl:variable name="playlists" select="/plist/dict/key[. = 'Playlists']/following-sibling::array/dict" />

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
			select="normalize-space(seq:remove-combining-characters(translate(replace(normalize-unicode($s, 'NFD'), '[&quot;%\[\]*?]', '_'), '\/:', '___')))"
		/>
	</xsl:function>

	<xsl:function name="seq:get-file-path">
		<xsl:param name="playlist" />

		<xsl:variable name="parentId" select="$playlist/key[. = 'Parent Persistent ID']/following-sibling::*[1]/text()" />
		<xsl:variable name="name" select="$playlist/key[. = 'Name']/following-sibling::*[1]/text()" />

		<xsl:if test="string-length($parentId)">
			<xsl:value-of select="seq:get-file-path($playlists[
				key[. = 'Playlist Persistent ID']/following-sibling::*[1]/text() eq $parentId
			])" />
			<xsl:text>/</xsl:text>
		</xsl:if>

		<xsl:value-of select="seq:normalize-for-path($name)" />
	</xsl:function>

	<xsl:function name="seq:get-href-for-playlist">
		<xsl:param name="parentId" />
		<xsl:param name="name" />
		<xsl:param name="position" />

		<xsl:variable name="filePath">
			<xsl:if test="string-length($parentId)">
				<xsl:value-of select="seq:get-file-path($playlists[
					key[. = 'Playlist Persistent ID']/following-sibling::*[1]/text() eq $parentId
				])" />
			</xsl:if>
		</xsl:variable>

		<xsl:variable name="fileName" select="seq:normalize-for-path($name)" />

		<xsl:choose>
			<xsl:when test="$destination">
				<xsl:value-of select="$destination" />
				<xsl:text>/Playlists/</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>Music Library/Playlists/</xsl:text>
			</xsl:otherwise>
		</xsl:choose>

		<xsl:if test="$filePath">
			<xsl:value-of select="$filePath" />
			<xsl:text>/</xsl:text>
		</xsl:if>
		<xsl:value-of select="$fileName" />

		<xsl:if test="number($position)">
			<xsl:text>&#32;(</xsl:text>
			<xsl:value-of select="$position" />
			<xsl:text>)</xsl:text>
		</xsl:if>

		<xsl:text>.m3u8</xsl:text>
	</xsl:function>

	<xsl:function name="seq:get-href-for-playlist">
		<xsl:param name="parentId" />
		<xsl:param name="name" />
		<xsl:value-of select="seq:get-href-for-playlist($parentId, $name, 0)" />
	</xsl:function>

	<xsl:template match="key[. = 'Playlists']">
		<xsl:variable
			name="playlists"
			select="following-sibling::array[1]/dict[
				key[. = 'Playlist Items'] and
				key[. = 'Playlist Items']/following-sibling::array[1]/* and
				not(key[. = 'Distinguished Kind']) and
				not(key[. = 'Smart Info']) and
				not(local-name(key[. = 'Folder']/following-sibling::*[1]) eq 'true') and
				not(local-name(key[. = 'Visible']/following-sibling::*[1]) eq 'false')
			]"
		/>

		<xsl:for-each select="$playlists">
			<xsl:variable name="parentId" select="key[. = 'Parent Persistent ID']/following-sibling::*[1]/text()" />
			<xsl:variable name="name" select="key[. = 'Name']/following-sibling::*[1]/text()" />

			<xsl:variable name="instances" select="$playlists[
				key[. = 'Parent Persistent ID']/following-sibling::*[1]/text() eq $parentId and key[. = 'Name']/following-sibling::*[1]/text() eq $name
			]" />

			<xsl:choose>
				<xsl:when test="count($instances) gt 1">
					<xsl:variable name="playlist" select="." />

					<xsl:for-each select="$instances">
						<xsl:if test=". = $playlist">
							<xsl:result-document href="{seq:get-href-for-playlist($parentId, $name, position())}" method="text">
								<xsl:apply-templates mode="playlist" select="array" />
							</xsl:result-document>
						</xsl:if>
					</xsl:for-each>
				</xsl:when>
				<xsl:otherwise>
					<xsl:result-document href="{seq:get-href-for-playlist($parentId, $name)}" method="text">
						<xsl:apply-templates mode="playlist" select="array" />
					</xsl:result-document>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>

	<!-- Playlist: #EXTM3U -->
	<xsl:template mode="playlist" match="array">
		<xsl:text>#EXTM3U</xsl:text>
		<xsl:text>&#13;</xsl:text>

		<xsl:for-each select="dict/key[. = 'Track ID']">
			<xsl:variable name="trackId" select="following-sibling::*[1]/text()" />
			<xsl:apply-templates mode="playlist-track" select="$tracks[1]/key[. = $trackId]/following-sibling::dict[1]" />
		</xsl:for-each>
	</xsl:template>

	<!-- Playlist track: #EXTINF -->
	<xsl:template mode="playlist-track" match="dict">
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
		<xsl:apply-templates select="plist/dict/key[. = 'Playlists']" />
	</xsl:template>
</xsl:stylesheet>
