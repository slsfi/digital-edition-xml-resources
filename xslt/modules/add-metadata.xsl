<xsl:stylesheet version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns:slsEdData="https://www.sls.fi/ns/digitaledition/metadata/"
	xmlns:slsFn="https://www.sls.fi/ns/digitaledition/functions/"
	exclude-result-prefixes="tei xs slsEdData slsFn"
>

	<!--
	XSLT Module: add-metadata.xsl
	Version: 1.0.0
	Author: Sebastian Köhler, Svenska litteratursällskapet i Finland,
		https://www.sls.fi/
	Created: 2025-01-15
	Changes:
		- 2025-01-15: v1.0.0

	Description:
	This XSLT module processes TEI-encoded documents and adds metadata that
	has been provided as input parameters to the XSLT processor. The metadata
	is written to a <xenoData> element in the <teiHeader>.

	Key Features:
	- Operates in the `add-metadata` mode with `on-no-match="shallow-copy"`,
	  ensuring that unmatched nodes are copied to the output without modification.
	- Supports the following input parameters, which are added as metadata to
	  the <xenoData> element:
		1. collectionId (int)
		2. publicationId (int)
		3. commentId (int)
		4. manuscriptId (int)
		5. variantId (int)
		6. publishedStatus (int)
		7. title (str)
		8. textType (str)
		9. sourceFile (str)
		10. dateOrigin (str)
		11. genre (str)
		12. language (str)

	Usage:
	Import or include this module in a main XSLT stylesheet and apply templates 
	using the `add-metadata` mode to execute the transformation.
	-->

	<!-- Declare input parameters, if undefined, set to empty sequence -->
	<xsl:param name="collectionId" as="xs:integer?" select="()"/>
	<xsl:param name="publicationId" as="xs:integer?" select="()"/>
	<xsl:param name="commentId" as="xs:integer?" select="()"/>
	<xsl:param name="manuscriptId" as="xs:integer?" select="()"/>
	<xsl:param name="variantId" as="xs:integer?" select="()"/>
	<xsl:param name="publishedStatus" as="xs:integer?" select="()"/>
	<xsl:param name="title" as="xs:string?" select="()"/>
	<xsl:param name="textType" as="xs:string?" select="()"/>
	<xsl:param name="sourceFile" as="xs:string?" select="()"/>
	<xsl:param name="dateOrigin" as="xs:string?" select="()"/>
	<xsl:param name="genre" as="xs:string?" select="()"/>
	<xsl:param name="language" as="xs:string?" select="()"/>

	<!-- Declare processing mode for this module -->
	<xsl:mode name="add-metadata" on-no-match="shallow-copy"/>

	<!--
	Match the <teiHeader> element and add <xenoData> element with publication
	metadata as last child of <teiHeader>, but before any <revisionDesc>
	-->
	<xsl:template match="tei:teiHeader" mode="add-metadata">
		<xsl:copy>
			<xsl:apply-templates select="@* | node()[not(self::tei:revisionDesc)]" mode="add-metadata"/>
			<xsl:if test="slsFn:any-parameter-exists($collectionId, $publicationId, $commentId, $manuscriptId, $variantId, $publishedStatus, $title, $textType, $sourceFile, $dateOrigin, $genre, $language)">
				<xsl:call-template name="generate-xenoData"/>
			</xsl:if>
			<xsl:if test="tei:revisionDesc">
				<xsl:text>	</xsl:text> <!-- Indentation -->
			</xsl:if>
			<xsl:apply-templates select="tei:revisionDesc" mode="add-metadata"/>
			<xsl:if test="tei:revisionDesc">
				<xsl:text>&#10;	</xsl:text> <!-- Line break and indentation -->
			</xsl:if>
		</xsl:copy>
	</xsl:template>

	<!--
	Template to generate the new <xenoData> element with proper indentation
	and line breaks
	-->
	<xsl:template name="generate-xenoData">
		<xsl:text>	</xsl:text> <!-- Indentation -->
		<xsl:element name="xenoData" namespace="http://www.tei-c.org/ns/1.0">
			<xsl:text>&#10;			</xsl:text> <!-- Line break and indentation -->
			<slsEdData:editionMetadata xmlns:slsEdData="https://www.sls.fi/ns/digitaledition/metadata/">
				<xsl:if test="normalize-space($title)">
					<xsl:text>&#10;				</xsl:text>
					<slsEdData:title>
						<xsl:value-of select="$title"/>
					</slsEdData:title>
				</xsl:if>
				<xsl:if test="normalize-space($textType)">
					<xsl:text>&#10;				</xsl:text>
					<slsEdData:textType>
						<xsl:value-of select="$textType"/>
					</slsEdData:textType>
				</xsl:if>
				<xsl:if test="normalize-space($sourceFile)">
					<xsl:text>&#10;				</xsl:text>
					<slsEdData:sourceFile>
						<xsl:value-of select="$sourceFile"/>
					</slsEdData:sourceFile>
				</xsl:if>
				<xsl:if test="normalize-space($dateOrigin)">
					<xsl:text>&#10;				</xsl:text>
					<slsEdData:dateOrigin>
						<xsl:value-of select="$dateOrigin"/>
					</slsEdData:dateOrigin>
				</xsl:if>
				<xsl:if test="normalize-space($genre)">
					<xsl:text>&#10;				</xsl:text>
					<slsEdData:genre>
						<xsl:value-of select="$genre"/>
					</slsEdData:genre>
				</xsl:if>
				<xsl:if test="normalize-space($language)">
					<xsl:text>&#10;				</xsl:text>
					<slsEdData:language>
						<xsl:value-of select="$language"/>
					</slsEdData:language>
				</xsl:if>
				<xsl:if test="exists($commentId)">
					<xsl:text>&#10;				</xsl:text>
					<slsEdData:commentId>
						<xsl:value-of select="$commentId"/>
					</slsEdData:commentId>
				</xsl:if>
				<xsl:if test="exists($manuscriptId)">
					<xsl:text>&#10;				</xsl:text>
					<slsEdData:manuscriptId>
						<xsl:value-of select="$manuscriptId"/>
					</slsEdData:manuscriptId>
				</xsl:if>
				<xsl:if test="exists($variantId)">
					<xsl:text>&#10;				</xsl:text>
					<slsEdData:variantId>
						<xsl:value-of select="$variantId"/>
					</slsEdData:variantId>
				</xsl:if>
				<xsl:if test="exists($publicationId)">
					<xsl:text>&#10;				</xsl:text>
					<slsEdData:publicationId>
						<xsl:value-of select="$publicationId"/>
					</slsEdData:publicationId>
				</xsl:if>
				<xsl:if test="exists($collectionId)">
					<xsl:text>&#10;				</xsl:text>
					<slsEdData:collectionId>
						<xsl:value-of select="$collectionId"/>
					</slsEdData:collectionId>
				</xsl:if>
				<xsl:if test="exists($publishedStatus)">
					<xsl:text>&#10;				</xsl:text>
					<slsEdData:publishedStatus>
						<xsl:value-of select="$publishedStatus"/>
					</slsEdData:publishedStatus>
				</xsl:if>
				<xsl:text>&#10;			</xsl:text>
			</slsEdData:editionMetadata>
			<xsl:text>&#10;		</xsl:text>
		</xsl:element>
		<xsl:text>&#10;	</xsl:text>
	</xsl:template>

	<!--
	Function for checking if input parameters have been set.
	Returns true if any of the input parameters have been set,
	otherwise false.
	-->
	<xsl:function name="slsFn:any-parameter-exists" as="xs:boolean">
		<xsl:param name="collectionId" as="xs:integer?"/>
		<xsl:param name="publicationId" as="xs:integer?"/>
		<xsl:param name="commentId" as="xs:integer?"/>
		<xsl:param name="manuscriptId" as="xs:integer?"/>
		<xsl:param name="variantId" as="xs:integer?"/>
		<xsl:param name="publishedStatus" as="xs:integer?"/>
		<xsl:param name="title" as="xs:string?"/>
		<xsl:param name="textType" as="xs:string?"/>
		<xsl:param name="sourceFile" as="xs:string?"/>
		<xsl:param name="dateOrigin" as="xs:string?"/>
		<xsl:param name="genre" as="xs:string?"/>
		<xsl:param name="language" as="xs:string?"/>

		<xsl:sequence select="
			exists($collectionId) or
			exists($publicationId) or
			exists($commentId) or
			exists($manuscriptId) or
			exists($variantId) or
			exists($publishedStatus) or
			normalize-space($title) or
			normalize-space($textType) or
			normalize-space($sourceFile) or
			normalize-space($dateOrigin) or
			normalize-space($genre) or
			normalize-space($language)
		"/>
	</xsl:function>

</xsl:stylesheet>