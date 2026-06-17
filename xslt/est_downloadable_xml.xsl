<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xml="http://www.w3.org/XML/1998/namespace"
	xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns:slsEdData="https://www.sls.fi/ns/digitaledition/metadata/"
	exclude-result-prefixes="tei xs"
>

	<!-- ******************************************************************
	*
	*    XSLT stylesheet: est_downloadable_xml.xsl
	*
	*    Version: 1.0.0
	*    Author:  Sebastian Köhler, Svenska litteratursällskapet i Finland,
	*             https://www.sls.fi/
	*    Created: 2026-06-17
	*    Licence: CC BY-NC 4.0 (Attribution-NonCommercial 4.0
	*             International),
	*             https://creativecommons.org/licenses/by-nc/4.0/
	*
	*    Changes:
	*        v1.0.0 (2026-06-17)
	*
	*    Description:
	*        This XSLT document processes a TEI-encoded reading-text XML
	*        document and serializes it as downloadable XML. By default,
	*        the output is an identity copy of the input document.
	*
	*        If the sectionId parameter is provided, the output is still
	*        copied as XML, but TEI <div> elements that are direct
	*        children of <body> in <text> are filtered. Only the <div>
	*        with a matching @xml:id value is included; unrelated <div>
	*        elements are omitted, and the matching <div> subtree is
	*        copied unchanged.
	*
	*    Input parameters:
	*        - sectionId (xs:string?, default: empty): The ID of the
	*          section of the input document which is to be copied. If no
	*          sectionId is provided, the whole document is copied.
	*
	*    Dependencies:
	*        None.
	*
	******************************************************************* -->


	<!-- * SERIALIZATION OPTIONS ************************************** -->

	<xsl:output method="xml" version="1.0" indent="no" encoding="UTF-8"
	            omit-xml-declaration="no"/>



	<!-- * PARAMETERS *****************************************************
	     * Declare input parameters. * -->

	<!-- * The sectionId parameter should not be used in the stylesheet,
	     * but rather the global variable derived from it,
	     * see below. * -->
	<xsl:param name="sectionId" as="xs:string?" select="()"/>



	<!-- * GLOBAL VARIABLES ******************************************* -->

	<!-- * Normalize $sectionId to be either a non-empty string or the
	     * empty sequence, and store in a global variable called
	     * $section-id. * -->
	<xsl:variable name="section-id" as="xs:string?"
	              select="if (string-length($sectionId) gt 0)
	                          then $sectionId else ()"/>



	<!-- * MODE DECLARATIONS ****************************************** -->

	<!-- * The unnamed, default mode. If unmatched, shallow copy copies
		 * nodes and attributes. *  -->
	<xsl:mode on-no-match="shallow-copy"/>



	<!-- * TEMPLATES ************************************************** -->
	
	<!-- * If section param given, copy only the matching section. -->
	<xsl:template match="tei:div[parent::tei:body[parent::tei:text]]">
		<xsl:choose>
			<xsl:when test="empty($section-id)">
				<xsl:copy>
					<xsl:apply-templates select="@* | node()"/>
				</xsl:copy>
			</xsl:when>
			<xsl:when test="@xml:id eq $section-id">
				<xsl:copy-of select="."/>
			</xsl:when>
			<xsl:otherwise/>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>
