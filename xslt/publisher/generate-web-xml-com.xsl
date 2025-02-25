<xsl:stylesheet version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns:slsEdData="https://www.sls.fi/ns/digitaledition/metadata/"
	exclude-result-prefixes="xs"
>

	<!--
	XSLT stylesheet: generate-web-xml-com.xsl
	Version 1.0.0
	Author: Sebastian Köhler, Svenska litteratursällskapet i Finland,
		https://www.sls.fi/
	Created: 2025-01-20
 	Changes:
		- 2025-01-20: v1.0.0

	Description:
	This XSLT document processes TEI-encoded comment documents and
	prepares them for web publication. First comment notes provided
	in the input parameter `notes` are transformed to TEI XML. Then
	the following transformations are performed on the source document:

	1. The processed comment notes are inserted in the <div type="notes">
	   element in the source document (if this element is not present, the
	   notes will not be inserted).
	2. Metadata is added based on input parameters.
	3. @xml:space is stripped from the <body> element, so subsequent
	   transformations can control whitespace output formatting.

	See the documentation for the individual modules for further details.

	Nodes not affected by the transformations in the aforementioned
	modules will be preserved in the output.

	Usage:
	Set input parameters on the XSLT processor (`notes`, for other parameters
	see `add-metadata.xsl`) and execute the transformation on a TEI-encoded
	XML source document.

	Output:
	A modified TEI-encoded XML document.
	-->

	<xsl:output method="xml" version="1.0" indent="no" encoding="UTF-8" omit-xml-declaration="no"/>

	<!-- Declare input parameters, if undefined, set to empty sequence -->
	<xsl:param name="notes" as="xs:string?" select="()"/>

	<!-- Import modules -->
	<xsl:import href="../modules/process-comment-notes.xsl"/>
	<xsl:import href="../modules/add-metadata.xsl"/>
	<xsl:import href="../modules/strip-xml-space.xsl"/>

	<!-- Entry point -->
	<xsl:template match="/">
		<!-- Parse the string parameter $notes as XML, then process and
		     store result in a variable so the comment notes can be
		     inserted in the source document in pass 1. -->
		<xsl:variable name="comment-notes" as="item()*">
			<xsl:try>
				<xsl:apply-templates select="parse-xml-fragment($notes)" mode="process-comment-notes"/>
				<xsl:catch>
					<xsl:sequence select="('Error parsing comment XML fragment.')"/>
				</xsl:catch>
			</xsl:try>
		</xsl:variable>

		<!-- Pass 1: Insert the processed notes into the source document
		     (the default context "."). -->
		<xsl:variable name="pass1-result">
			<xsl:apply-templates select="." mode="insert-comment-notes">
				<!-- Pass along the processed comment notes as a parameter. -->
				<xsl:with-param name="notes-to-add" select="$comment-notes"/>
			</xsl:apply-templates>
		</xsl:variable>

		<!-- Pass 2: Add metadata -->
		<xsl:variable name="pass2-result">
			<xsl:apply-templates select="$pass1-result" mode="add-metadata"/>
		</xsl:variable>

		<!-- Pass 3: Strip @xml:space from <body> -->
		<xsl:variable name="pass3-result">
			<xsl:apply-templates select="$pass2-result" mode="strip-xml-space"/>
		</xsl:variable>
		
		<!-- Output the final result -->
		<xsl:sequence select="$pass3-result"/>
	</xsl:template>
		
	<!-- Mode and template for inserting the comment notes into
	     the main document using the "insert-comment-notes" mode. -->
	<!-- Declare processing mode for inserting comment notes -->
	<xsl:mode name="insert-comment-notes" on-no-match="shallow-copy"/>

	<!-- Inserts the new notes into <tei:div type="notes"> -->
	<xsl:template match="tei:div[@type eq 'notes']" mode="insert-comment-notes">
		<xsl:param name="notes-to-add" as="item()*"/>
		<xsl:copy>
			<!-- Copy existing attributes & children first -->
			<xsl:apply-templates select="@* | node()" mode="insert-comment-notes"/>
			<!-- Append the newly processed notes -->
			<xsl:copy-of select="$notes-to-add"/>
			<xsl:text>&#10;			</xsl:text> <!-- Line break and indentation -->
		</xsl:copy>
	</xsl:template>

</xsl:stylesheet>