<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xml="http://www.w3.org/XML/1998/namespace"
	xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns:slsFn="https://www.sls.fi/ns/digitaledition/functions/"
	exclude-result-prefixes="#all"
	expand-text="yes"
>

	<!-- ******************************************************************
	*
	*    XSLT stylesheet: required-global-variables.xsl
	*
	*    Version: 1.0.1
	*    Author:  Sebastian Köhler, Svenska litteratursällskapet i Finland,
	*             https://www.sls.fi/
	*    Created: 2025-03-10
	*    Licence: CC-BY-NC 4.0 (Attribution-NonCommercial 4.0
	*             International),
	*             https://creativecommons.org/licenses/by-nc/4.0/
	*
	*    Changes:
	*        v1.0.1 (2025-04-22)
	*             - Change the `icons-base-path` variable to non-static.
	*        v1.0.0 (2025-03-10)
	*
	*    Description:
	*        This XSLT document defines common global variables that are
	*        used by multiple XSLT documents.
	*
	******************************************************************* -->


	<!-- * GLOBAL VARIABLES ******************************************* -->

	<!-- * Newline (hexadecimal 0A, decimal 10). * -->
	<xsl:variable name="NL" as="xs:string" static="yes"
	              select="'&#xA;'"/>

	<!-- * No-Break Space (hexadecimal A0, decimal 160) * -->
	<xsl:variable name="NBSP" as="xs:string" static="yes"
	              select="'&#xA0;'"/>

	<!-- * Directory base path where icon images are located on the
	     * frontend. * -->
	<xsl:variable name="icons-base-path" as="xs:string"
	              select="'assets/images'"/>

	<!-- * Image element with icon representing empty content. * -->
	<xsl:variable name="empty-icon-image" as="element(img)">
		<img src="{$icons-base-path}/squared_times_gray.svg"
		     alt="tomt" loading="lazy" aria-hidden="true"/>
	</xsl:variable>

</xsl:stylesheet>