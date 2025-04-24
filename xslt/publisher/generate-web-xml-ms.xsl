<xsl:stylesheet version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns:slsEdData="https://www.sls.fi/ns/digitaledition/metadata/"
	exclude-result-prefixes="xs"
>

	<!-- ******************************************************************
	*
	*    XSLT stylesheet: generate-web-xml-ms.xsl
	*    Version: 1.0.0
	*    Author:  Sebastian Köhler, Svenska litteratursällskapet i Finland,
	*             https://www.sls.fi/
	*    Created: 2025-02-13
	*    Licence: CC-BY-NC 4.0 (Attribution-NonCommercial 4.0
	*             International),
	*             https://creativecommons.org/licenses/by-nc/4.0/
	*
	*    Changes:
	*        v1.0.0 (2025-02-13)
	*
	*    Description:
	*        This XSLT document processes TEI-encoded manuscript documents
	*        and prepares them for web publication. The following
	*        transformations are performed on the source document:
	*
	*        1. <anchor> elements related to comment notes (@xml:id starts
	*           with `start` or `end`) are removed.
	*        2. Line beginning elements indicating word or line breaks are
	*           converted to hard line break elements.
	*        3. Metadata is added based on input parameters.
	*        4. @xml:space is stripped from the <body> element, so
	*           subsequent transformations can control whitespace output
	*           formatting.
	*
	*        See the documentation for the individual modules for further
	*        details.
	*
	*        Nodes not affected by the transformations in the
	*        aforementioned modules will be preserved in the output.
	*
	*    Usage:
	*        Set input parameters on the XSLT processor (see
	*        `add-metadata.xsl`) and execute the transformation on a
	*        TEI-encoded XML source document.
	*
	*    Output:
	*        A modified TEI-encoded XML document.
	*
	******************************************************************* -->


	<!-- * SERIALIZATION OPTIONS ************************************** -->

	<xsl:output method="xml" version="1.0" indent="no" encoding="UTF-8"
	            omit-xml-declaration="no"/>



	<!-- * IMPORTS **************************************************** -->

	<xsl:import href="../modules/remove-comment-anchors.xsl"/>
	<xsl:import href="../modules/process-lb-breaks.xsl"/>
	<xsl:import href="../modules/add-metadata.xsl"/>
	<xsl:import href="../modules/strip-xml-space.xsl"/>



	<!-- * TEMPLATES ************************************************** -->

	<!-- * Entry point. * -->
	<xsl:template match="/">
		<!-- * Pass 1: Remove comment anchor elements. * -->
		<xsl:variable name="pass1-result">
			<xsl:apply-templates select="/" mode="remove-comment-anchors"/>
		</xsl:variable>

		<!-- * Pass 2: Process lb breaks (preserve). * -->
		<xsl:variable name="pass2-result">
			<xsl:apply-templates select="$pass1-result" mode="preserve-lb-breaks"/>
		</xsl:variable>

		<!-- * Pass 3: Add metadata. * -->
		<xsl:variable name="pass3-result">
			<xsl:apply-templates select="$pass2-result" mode="add-metadata"/>
		</xsl:variable>

		<!-- * Pass 4: Strip @xml:space from <body>. * -->
		<xsl:variable name="pass4-result">
			<xsl:apply-templates select="$pass3-result" mode="strip-xml-space"/>
		</xsl:variable>

		<!-- * Output the final result. * -->
		<xsl:sequence select="$pass4-result"/>
	</xsl:template>

</xsl:stylesheet>