<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xml="http://www.w3.org/XML/1998/namespace"
	xmlns:map="http://www.w3.org/2005/xpath-functions/map"
	xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns:slsFn="https://www.sls.fi/ns/digitaledition/functions/"
	exclude-result-prefixes="#all"
	expand-text="yes"
>

	<!-- ******************************************************************
	*
	*    XSLT stylesheet: ms_changes.xsl
	*
	*    Version: 1.0.0
	*    Author:  Sebastian Köhler, Svenska litteratursällskapet i Finland,
	*             https://www.sls.fi/
	*    Created: 2025-04-22
	*    Licence: CC-BY-NC 4.0 (Attribution-NonCommercial 4.0
	*             International),
	*             https://creativecommons.org/licenses/by-nc/4.0/
	*
	*    Changes:
	*        v1.0.0 (2025-04-22)
	*
	*    Description:
	*        This XSLT document processes a TEI-encoded manuscript XML
	*        document and transforms it to HTML5 for inclusion on the
	*        project website. The input document should be a preprocessed
	*        manuscript ("ms") XML document, generated with the SLS
	*        Digital Edition API publisher script. The stylesheet produces
	*        a version of the manuscript where all changes are retained.
	*
	*        The generated HTML5 output is not a complete HTML document,
	*        but an HTML fragment, which can be incorporated in an HTML
	*        page.
	*
	*    Input parameters:
	*        - bookId (xs:string?, default: empty): The ID of the text
	*          collection that the document is included in. Can be used
	*          to process texts of different collections differently.
	*          Currently not used.
	*        - sectionId (xs:string?, default: empty): The ID of the
	*          section of the input document which is to be processed. If
	*          no sectionId is provided, the whole document is processed.
	*        - debug (xs:boolean?, default: false): Run transformation in
	*          debug ”mode” with additional output for easier debugging.
	*
	******************************************************************* -->


	<!-- * SERIALIZATION OPTIONS ************************************** -->

	<xsl:output method="html" html-version="5.0" encoding="utf-8"
	            include-content-type="no" indent="no"/>

	<xsl:strip-space elements="tei:TEI tei:address tei:argument tei:body
	                           tei:cit tei:closer tei:div tei:epigraph
	                           tei:lg tei:list tei:opener tei:postscript
	                           tei:row tei:table tei:teiHeader tei:text"/>



	<!-- * IMPORTS **************************************************** -->

	<xsl:import href="required-global-variables.xsl"/>
	<xsl:import href="shared-functions.xsl"/>
	<xsl:import href="shared-named-templates.xsl"/>



	<!-- * PARAMETERS *****************************************************
	     * Declare input parameters. * -->

	<!-- * The bookId and sectionId parameters should not be used in the
	     * stylesheet, but rather the global variables derived from these,
	     * see below. * -->
	<xsl:param name="bookId" as="xs:string?" select="()"/>
	<xsl:param name="sectionId" as="xs:string?" select="()"/>

	<!-- * Parameter for enabling debug ”mode”. * -->
	<xsl:param name="debug" as="xs:boolean?" select="false()"/>



	<!-- * GLOBAL VARIABLES ******************************************* -->

	<!-- * Normalize $bookId to be either a non-empty string or the empty
	     * sequence, and store in a global variable called
	     * $collection-id. * -->
	<xsl:variable name="collection-id" as="xs:string?"
	              select="if (string-length($bookId) gt 0)
	                          then $bookId else ()"/>

	<!-- * Normalize $sectionId to be either a non-empty string or the
	     * empty sequence, and store in a global variable called
	     * $section-id. * -->
	<xsl:variable name="section-id" as="xs:string?"
	              select="if (string-length($sectionId) gt 0)
	                          then $sectionId else ()"/>

	<!-- * An integer offset to add to the heading levels in the output.
	     * If set to 0, the top-most heading will be a <h1>, if set to 1,
	     * the top-most heading will be a <h2>, etc. Because the output
	     * HTML is embedded in a webpage with pre-existing headings, the
	     * heading levels need to be offset. * -->
	<xsl:variable name="heading-level-offset" as="xs:integer" static="yes"
	              select="2"/>

	<!-- * Mapping of medium values. * -->
	<xsl:variable name="medium-map" as="map(xs:string, xs:string)"
	              static="yes"
	              select="map {
	                           'black-ink':        'svart bläck',
	                           'black-inkOther':   'annat svart bläck',
	                           'blue-ink':         'blått bläck',
	                           'blue-pen':         'blå kulspetspenna',
	                           'blue-pencil':      'blå färgpenna',
	                           'brown-ink':        'brunt bläck',
	                           'brown-inkOther':   'annat brunt bläck',
	                           'green-ink':        'grönt bläck',
	                           'green-pen':        'grön kulspetspenna',
	                           'green-pencil':     'grön färgpenna',
	                           'red-ink':          'rött bläck',
	                           'red-pen':          'röd kulspetspenna',
	                           'red-pencil':       'röd färgpenna',
	                           'violet-ink':       'violett bläck',
	                           'indeliblePencil':  'anilinpenna',
	                           'pencil':           'blyertspenna',
	                           'typewrite':        'maskinskrivet'
	                           }"/>



	<!-- * TEMPLATES ******************************************************
	     * Reminder on XSLT default behaviour for unmatched nodes:
	     * element nodes are unwrapped and children processed (same as
	     * apply-templates applied to them); the content (text) of text
	     * nodes is outputted. * -->

	<xsl:template match="tei:teiHeader"/>


	<xsl:template match="tei:body[not(parent::tei:floatingText)]">
	<!-- * Template for <body> elements that are not children of
	     * <floatingText>. If the global parameter $section-id is set,
	     * process only the <div> with matching @xml:id. The content
	     * of <body> is wrapped in <section> if it contains a child
	     * <head>, otherwise in a <div>. @class is set with the @type
	     * of the parent, <text>. Also @xml:id and @xml:lang are
	     * inherited from <text>. Any footnotes either in the whole
	     * <body> or just the processed section-id are appended as a
	     * <section>. * -->
		<xsl:choose>
			<xsl:when test="exists($section-id)">
				<xsl:apply-templates select="//tei:div[@xml:id eq $section-id]"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="class-names" as="xs:string*"
				              select="(if (parent::tei:text[@type])
				                           then parent::tei:text/@type
				                       else 'prose')"/>
				<xsl:variable name="element-name" as="xs:string"
				              select="if (tei:head)
				                          then 'section'
				                      else 'div'"/>

				<xsl:choose>
					<xsl:when test="$element-name eq 'div' and empty($class-names)
					                and not(parent::tei:text[@xml:id])
					                and not(parent::tei:text[@xml:lang])">
						<xsl:apply-templates/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:element name="{$element-name}">
							<xsl:call-template name="set-attr-from-parent-xml-id"/>
							<xsl:call-template name="set-attr-from-parent-xml-lang"/>
							<xsl:call-template name="set-class-attr">
								<xsl:with-param name="class-names"
								                select="$class-names"/>
							</xsl:call-template>

							<xsl:call-template name="wrap-head-opener-in-hgroup">
								<xsl:with-param name="nodes" select="node()"/>
							</xsl:call-template>
						</xsl:element>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>

		<!-- * Process any footnotes so they appear after the main text. * -->
		<xsl:call-template name="list-footnotes">
			<xsl:with-param name="section-id" select="$section-id"/>
		</xsl:call-template>
	</xsl:template>


	<xsl:template match="tei:div">
	<!-- * If the <div> has a <head> child or @type of the <div> is
	     * 'letterpart', wrap in <section>, otherwise in a <div>. However,
	     * a <div> without attributes will not be outputted. The @type
	     * value will be added as a class name to @class, and if the type
	     * changes, the class name 'incorp' will also be added. * -->
		<xsl:variable name="class-names" as="xs:string*"
			select="(@type,
		             if (ancestor::tei:div[@type][1]/@type ne current()/@type
		                 or (parent::tei:body
			                 and ancestor::tei:text/@type ne current()/@type))
			         then 'incorp' else ())"/>
		<xsl:variable name="element-name" as="xs:string"
		              select="if (*[self::tei:head] or (@type eq 'letterpart'))
		                          then 'section'
		                      else 'div'"/>

		<xsl:choose>
			<xsl:when test="$element-name eq 'div' and empty($class-names)
			                and not(@xml:id) and not(@xml:lang)">
				<xsl:apply-templates/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:element name="{$element-name}">
					<xsl:call-template name="set-attr-from-xml-id"/>
					<xsl:call-template name="set-attr-from-xml-lang"/>
					<xsl:call-template name="set-class-attr">
						<xsl:with-param name="class-names" select="$class-names"/>
					</xsl:call-template>

					<xsl:call-template name="wrap-head-opener-in-hgroup">
						<xsl:with-param name="nodes" select="node()"/>
					</xsl:call-template>
				</xsl:element>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template match="tei:floatingText">
	<!-- * Wrap content in <section> if <floatingText> has a <body> child
	     * with a <head> as its first child, otherwise wrap in <div>. * -->
		<xsl:variable name="element-name" as="xs:string"
		              select="if (tei:body/tei:head[not(preceding-sibling::*)])
		                          then 'section'
		                      else 'div'"/>

		<xsl:element name="{$element-name}">
			<xsl:call-template name="set-class-attr">
				<xsl:with-param name="class-names"
				                select="(if (@type) then @type else 'prose',
				                         'incorp')"/>
			</xsl:call-template>
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>


	<xsl:template match="tei:opener">
	<!--* Wrap in a <div> if not part of a grouping which will be wrapped
		* in <hgroup>, otherwise, just apply templates. * -->
		<xsl:choose>
			<xsl:when test="not(current-grouping-key() eq 'hgroup')
			                or (current-grouping-key() eq 'hgroup'
				                and count(current-group()) lt 2)">
				<div class="opener">
					<xsl:apply-templates/>
				</div>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template match="tei:closer | tei:postscript">
		<div class="{local-name()}">
			<xsl:apply-templates/>
		</div>
	</xsl:template>


	<xsl:template match="tei:head[not(parent::tei:figure)
	                              and not(parent::tei:table)
	                              and not(@type eq 'subtitle')]">
		<xsl:variable name="heading-level"
		              select="slsFn:get-heading-level(., $heading-level-offset)"/>
		<xsl:variable name="element-name"
		              select="if ($heading-level lt 7)
		                          then 'h' || $heading-level
		                      else 'div'"/>

		<xsl:variable name="in-addspan" select="slsFn:is-in-addspan(.)"/>
    	<xsl:variable name="in-delspan" select="slsFn:is-in-delspan(.)"/>
		<xsl:variable name="addspan-hand-attr"
		              select="preceding::tei:addSpan[1]/@hand"/>
		<xsl:variable name="delspan-hand-attr"
		              select="preceding::tei:delSpan[1]/@hand"/>

		<xsl:element name="{$element-name}">
			<xsl:if test="$element-name eq 'div'">
				<xsl:attribute name="role" select="'heading'"/>
				<xsl:attribute name="aria-level" select="$heading-level"/>
			</xsl:if>
			<xsl:call-template name="set-class-attr">
				<xsl:with-param name="class-names"
					select="(if (@type) then @type else 'chapter',
					         @rend,
					         if (@hand) then 'hand tooltiptrigger ttMs' else (),
					         if ($in-addspan)
		                         then (if ($addspan-hand-attr)
		                                   then 'addSpanHand'
		                               else 'addSpan')
		                     else (),
		                     if ($in-delspan)
		                         then (if ($delspan-hand-attr)
		                                   then 'delSpanHand'
		                               else 'delSpan')
		                     else ())"/>
			</xsl:call-template>
			<xsl:apply-templates/>
		</xsl:element>
		<xsl:call-template name="render-hand-tooltip">
			<xsl:with-param name="hand-attr" select="@hand"/>
		</xsl:call-template>
	</xsl:template>


	<xsl:template match="tei:head[@type eq 'subtitle']">
		<xsl:variable name="in-addspan" select="slsFn:is-in-addspan(.)"/>
    	<xsl:variable name="in-delspan" select="slsFn:is-in-delspan(.)"/>
		<xsl:variable name="addspan-hand-attr"
		              select="preceding::tei:addSpan[1]/@hand"/>
		<xsl:variable name="delspan-hand-attr"
		              select="preceding::tei:delSpan[1]/@hand"/>

		<p role="doc-subtitle">
			<xsl:call-template name="set-class-attr">
				<xsl:with-param name="class-names"
					select="(@rend,
				            if (@hand) then 'hand tooltiptrigger ttMs' else (),
					        if ($in-addspan)
		                        then (if ($addspan-hand-attr)
		                                  then 'addSpanHand'
		                              else 'addSpan')
		                    else (),
		                    if ($in-delspan)
		                        then (if ($delspan-hand-attr)
		                                  then 'delSpanHand'
		                              else 'delSpan')
		                    else ())"/>
			</xsl:call-template>
			<xsl:apply-templates/>
		</p>
		<xsl:call-template name="render-hand-tooltip">
			<xsl:with-param name="hand-attr" select="@hand"/>
		</xsl:call-template>
	</xsl:template>


	<xsl:template match="tei:ab[parent::tei:epigraph] |
	                     tei:address |
	                     tei:bibl[ancestor::tei:opener] |
	                     tei:byline |
	                     tei:dateline |
	                     tei:p[parent::tei:argument] |
	                     tei:salute |
	                     tei:signed">
		<xsl:variable name="in-addspan" select="slsFn:is-in-addspan(.)"/>
    	<xsl:variable name="in-delspan" select="slsFn:is-in-delspan(.)"/>
		<xsl:variable name="addspan-hand-attr"
		              select="preceding::tei:addSpan[1]/@hand"/>
		<xsl:variable name="delspan-hand-attr"
		              select="preceding::tei:delSpan[1]/@hand"/>

		<p>
			<xsl:call-template name="set-attr-from-xml-lang"/>
			<xsl:call-template name="set-class-attr">
				<xsl:with-param name="class-names"
				                select="(if (parent::tei:argument)
				                             then 'argument'
				                         else if (not(local-name() eq 'p'))
				                             then local-name() else (),
				                         if (ancestor::tei:epigraph)
				                             then 'epigraph' else (),
				                         @rend,
					                     if ($in-addspan)
					                         then (if ($addspan-hand-attr)
					                                   then 'addSpanHand'
					                               else 'addSpan')
					                     else (),
					                     if ($in-delspan)
					                         then (if ($delspan-hand-attr)
					                                   then 'delSpanHand'
					                               else 'delSpan')
					                     else ())"/>
			</xsl:call-template>
			<xsl:apply-templates/>
		</p>
	</xsl:template>


	<xsl:template match="tei:addrLine">
		<xsl:call-template name="apply-templates-with-spanning-markup"/>
		<xsl:if test="not(. is (ancestor::tei:address//tei:addrLine[last()]))">
			<br/><xsl:text>{if ($debug) then $NL else ''}</xsl:text>
		</xsl:if>
	</xsl:template>


	<xsl:template match="tei:p">
		<xsl:variable name="in-addspan" select="slsFn:is-in-addspan(.)"/>
    	<xsl:variable name="in-delspan" select="slsFn:is-in-delspan(.)"/>
		<xsl:variable name="addspan-hand-attr"
		              select="preceding::tei:addSpan[1]/@hand"/>
		<xsl:variable name="delspan-hand-attr"
		              select="preceding::tei:delSpan[1]/@hand"/>

		<p>
			<xsl:call-template name="set-attr-from-xml-id"/>
			<xsl:call-template name="set-attr-from-xml-lang"/>
			<xsl:call-template name="set-class-attr">
				<xsl:with-param name="class-names"
				                select="(@rend,
					                     if ($in-addspan)
					                         then (if ($addspan-hand-attr)
					                                   then 'addSpanHand'
					                               else 'addSpan')
					                     else (),
					                     if ($in-delspan)
					                         then (if ($delspan-hand-attr)
					                                   then 'delSpanHand'
					                               else 'delSpan')
					                     else ())"/>
			</xsl:call-template>
			<xsl:apply-templates/>
			<xsl:call-template name="render-transpose-end-mark"/>
		</p>
	</xsl:template>


	<xsl:template match="tei:quote">
		<xsl:variable name="in-addspan" select="slsFn:is-in-addspan(.)"/>
    	<xsl:variable name="in-delspan" select="slsFn:is-in-delspan(.)"/>
		<xsl:variable name="addspan-hand-attr"
		              select="preceding::tei:addSpan[1]/@hand"/>
		<xsl:variable name="delspan-hand-attr"
		              select="preceding::tei:delSpan[1]/@hand"/>
		<xsl:variable name="element-name" as="xs:string"
		              select="if (@type eq 'block' and not(ancestor::tei:opener))
		                          then 'blockquote'
		                      else 'p'"/>

		<xsl:element name="{$element-name}">
			<xsl:call-template name="set-attr-from-xml-lang"/>
			<xsl:call-template name="set-class-attr">
				<xsl:with-param name="class-names"
				                select="(if ($element-name eq 'p')
				                             then 'quote' else (),
				                         if (ancestor::tei:epigraph)
				                             then 'epigraph' else (),
				                         if ($in-addspan)
					                         then (if ($addspan-hand-attr)
					                                   then 'addSpanHand'
					                               else 'addSpan')
					                     else (),
					                     if ($in-delspan)
					                         then (if ($delspan-hand-attr)
					                                   then 'delSpanHand'
					                               else 'delSpan')
					                     else ())"/>
			</xsl:call-template>
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>


	<xsl:template match="tei:q[@rend eq 'parIndent']">
		<div class="q parIndent">
			<xsl:apply-templates/>
		</div>
	</xsl:template>


	<xsl:template match="tei:lg">
		<xsl:variable name="in-addspan" select="slsFn:is-in-addspan(.)"/>
    	<xsl:variable name="in-delspan" select="slsFn:is-in-delspan(.)"/>
		<xsl:variable name="addspan-hand-attr"
		              select="preceding::tei:addSpan[1]/@hand"/>
		<xsl:variable name="delspan-hand-attr"
		              select="preceding::tei:delSpan[1]/@hand"/>

		<p>
			<xsl:call-template name="set-attr-from-xml-id"/>
			<xsl:call-template name="set-attr-from-xml-lang"/>
			<xsl:call-template name="set-class-attr">
				<xsl:with-param name="class-names"
				                select="('lg',
				                         @type,
				                         if ($in-addspan)
					                         then (if ($addspan-hand-attr)
					                                   then 'addSpanHand'
					                               else 'addSpan')
					                     else (),
					                     if ($in-delspan)
					                         then (if ($delspan-hand-attr)
					                                   then 'delSpanHand'
					                               else 'delSpan')
					                     else ())"/>
			</xsl:call-template>
			<xsl:apply-templates/>
			<xsl:call-template name="render-transpose-end-mark"/>
		</p>
	</xsl:template>


	<xsl:template match="tei:l">
		<xsl:variable name="lg-type" as="xs:string?"
		              select="parent::tei:lg/@type"/>
		<xsl:variable name="line-label" as="xs:string?"
		              select="if ($lg-type eq 'labelledLinesBefore'
				                  or $lg-type eq 'labelledLinesAfter')
				                  then $lg-type else ()"/>
		<xsl:variable name="in-addspan" select="slsFn:is-in-addspan(.)"/>
    	<xsl:variable name="in-delspan" select="slsFn:is-in-delspan(.)"/>
		<xsl:variable name="addspan-hand-attr"
		              select="preceding::tei:addSpan[1]/@hand"/>
		<xsl:variable name="delspan-hand-attr"
		              select="preceding::tei:delSpan[1]/@hand"/>

		<span>
			<xsl:call-template name="set-attr-from-xml-id"/>
			<xsl:call-template name="set-attr-from-xml-lang"/>
			<xsl:call-template name="set-class-attr">
				<xsl:with-param name="class-names"
				                select="('l', @rend,
				                         if (@part)
				                             then 'part' || @part else (),
				                         if ($in-addspan)
					                         then (if ($addspan-hand-attr)
					                                   then 'addSpanHand'
					                               else 'addSpan')
					                     else (),
					                     if ($in-delspan)
					                         then (if ($delspan-hand-attr)
					                                   then 'delSpanHand'
					                               else 'delSpan')
					                     else ())"/>
			</xsl:call-template>
			<xsl:choose>
				<xsl:when test="$line-label and tei:label">
					<xsl:choose>
						<xsl:when test="tei:label is node()[1]">
							<span class="lLabel">
								<xsl:apply-templates select="tei:label"/>
							</span>
							<span>
								<xsl:apply-templates select="node() except tei:label"/>
								<xsl:call-template name="render-transpose-end-mark"/>
							</span>
						</xsl:when>
						<xsl:otherwise>
							<span>
								<xsl:apply-templates select="node() except tei:label"/>
							</span>
							<span class="lLabel">
								<xsl:apply-templates select="tei:label"/>
								<xsl:call-template name="render-transpose-end-mark"/>
							</span>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates/>
					<xsl:call-template name="render-transpose-end-mark"/>
				</xsl:otherwise>
			</xsl:choose>
		</span>

		<xsl:variable name="last-line" as="element(tei:l)?"
		              select="((ancestor::tei:lg[1]//tei:l)
		                      except (ancestor::tei:lg[1]//tei:lg//tei:l))[last()]"/>
		<xsl:if test="not(. is $last-line)">
			<br/><xsl:text>{if ($debug) then $NL else ''}</xsl:text>
		</xsl:if>
	</xsl:template>


	<xsl:template match="tei:label">
		<xsl:choose>
			<xsl:when test="parent::tei:lg[@type eq 'labelledAbove'
			                               or @type eq 'labelledMargin']
			                and @place">
				<span class="label{substring(@place, 1, 1) => upper-case()}{substring(@place, 2)}">
					<xsl:call-template name="apply-templates-with-spanning-markup"/>
				</span><xsl:text>{if ($debug) then $NL else ''}</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="apply-templates-with-spanning-markup"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template match="tei:list">
	<!-- * @rend values 'indent', 'disc' and 'dash' and missing @rend
	     * results in an unordered list, otherwise an ordered list. * -->
		<xsl:variable name="in-addspan" select="slsFn:is-in-addspan(.)"/>
    	<xsl:variable name="in-delspan" select="slsFn:is-in-delspan(.)"/>
		<xsl:variable name="addspan-hand-attr" select="preceding::tei:addSpan[1]/@hand"/>
		<xsl:variable name="delspan-hand-attr" select="preceding::tei:delSpan[1]/@hand"/>

		<xsl:element name="{if (not(@rend) or @rend eq 'indent'
		                        or @rend eq 'disc' or @rend eq 'dash')
		                        then 'ul'
		                    else 'ol'}">
			<xsl:call-template name="set-attr-from-xml-lang"/>
			<xsl:call-template name="set-class-attr">
				<xsl:with-param name="class-names"
				                select="(if (@rend)
				                             then @rend
				                         else 'plain',
				                         if (parent::tei:argument)
				                             then 'argument' else (),
				                         if ($in-addspan)
					                         then (if ($addspan-hand-attr)
					                                   then 'addSpanHand'
					                               else 'addSpan')
					                     else (),
					                     if ($in-delspan)
					                         then (if ($delspan-hand-attr)
					                                   then 'delSpanHand'
					                               else 'delSpan')
					                     else ())"/>
			</xsl:call-template>
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>
	
	
	<xsl:template match="tei:item">
		<li>
			<xsl:call-template name="set-attr-from-xml-lang"/>
			<xsl:call-template name="apply-templates-with-spanning-markup"/>
		</li>
	</xsl:template>


	<xsl:template match="tei:table">
		<xsl:variable name="in-addspan" select="slsFn:is-in-addspan(.)"/>
    	<xsl:variable name="in-delspan" select="slsFn:is-in-delspan(.)"/>
		<xsl:variable name="addspan-hand-attr"
		              select="preceding::tei:addSpan[1]/@hand"/>
		<xsl:variable name="delspan-hand-attr"
		              select="preceding::tei:delSpan[1]/@hand"/>

		<!-- * Tables are wrapped in a <div> so large tables can be
			   scrolled horizontally. -->
		<div class="table-wrapper">
			<table>
				<xsl:call-template name="set-attr-from-xml-id"/>
				<xsl:call-template name="set-attr-from-xml-lang"/>
				<xsl:call-template name="set-class-attr">
					<xsl:with-param name="class-names"
					                select="(@rend,
					                         if ($in-addspan)
						                         then (if ($addspan-hand-attr)
						                                   then 'addSpanHand'
						                               else 'addSpan')
						                     else (),
						                     if ($in-delspan)
						                         then (if ($delspan-hand-attr)
						                                   then 'delSpanHand'
						                               else 'delSpan')
						                     else ())"/>
				</xsl:call-template>

				<!-- * Group the rows so the first child rows with
					 * @role="label" are wrapped in <thead> and the
					 * subsequent rows are wrapped in <tbody>. * -->
				<xsl:for-each-group select="node()"
					group-adjacent="if (self::tei:row[@role eq 'label']
					                    and (not(preceding-sibling::*)
					                         or preceding-sibling::tei:row[1][@role eq 'label']))
				                        then 'thead'
				                    else 'tbody'">
					<xsl:element name="{current-grouping-key()}">
						<xsl:for-each select="current-group()">
							<xsl:apply-templates select="."/>
						</xsl:for-each>
					</xsl:element>
				</xsl:for-each-group>
			</table>
		</div>
	</xsl:template>


	<xsl:template match="tei:head[parent::tei:table]">
		<caption>
			<xsl:call-template name="set-class-attr-from-rend"/>
			<xsl:call-template name="apply-templates-with-spanning-markup"/>
		</caption>
	</xsl:template>


	<xsl:template match="tei:row">
		<tr><xsl:apply-templates/></tr>
	</xsl:template>


	<xsl:template match="tei:cell">
		<xsl:variable name="is-header" as="xs:boolean"
		              select="if (parent::tei:row[@role eq 'label']
		                          or @role eq 'label')
		                          then true()
		                      else false()"/>
		<xsl:variable name="colspan" as="xs:integer?"
		              select="let $parent-cols := parent::tei:row/@cols,
		                          $cols-str := if ($parent-cols)
		                                           then $parent-cols
		                                       else @cols,
		                          $cols-int := if ($cols-str castable as xs:integer)
		                                           then xs:integer($cols-str) else ()
		                      return if ($cols-int gt 1)
		                                 then $cols-int else ()"/>
		<xsl:variable name="rowspan" as="xs:integer?"
		              select="let $rows-int := if (@rows castable as xs:integer)
		                                           then xs:integer(@rows) else ()
		                      return if ($rows-int gt 1)
		                                 then $rows-int else ()"/>
		<xsl:variable name="in-addspan" select="slsFn:is-in-addspan(.)"/>
    	<xsl:variable name="in-delspan" select="slsFn:is-in-delspan(.)"/>
		<xsl:variable name="addspan-hand-attr"
		              select="preceding::tei:addSpan[1]/@hand"/>
		<xsl:variable name="delspan-hand-attr"
		              select="preceding::tei:delSpan[1]/@hand"/>

		<xsl:element name="{if ($is-header) then 'th' else 'td'}">
			<xsl:call-template name="set-attr-from-xml-lang"/>
			<xsl:call-template name="set-class-attr">
				<xsl:with-param name="class-names"
				                select="(distinct-values((@rend,
				                                         parent::tei:row/@rend)),
				                         if ($in-addspan)
					                         then (if ($addspan-hand-attr)
					                                   then 'addSpanHand'
					                               else 'addSpan')
					                     else (),
					                     if ($in-delspan)
					                         then (if ($delspan-hand-attr)
					                                   then 'delSpanHand'
					                               else 'delSpan')
					                     else ())"/>
			</xsl:call-template>
			<xsl:where-populated>
				<xsl:attribute name="colspan" select="$colspan"/>
			</xsl:where-populated>
			<xsl:where-populated>
				<xsl:attribute name="rowspan" select="$rowspan"/>
			</xsl:where-populated>
			<xsl:where-populated>
				<xsl:attribute name="scope"
				               select="if ($is-header and $colspan)
				                           then 'colgroup'
				                       else if ($is-header and $rowspan)
				                           then 'rowgroup'
				                       else if (@role eq 'label'
				                                and not(preceding-sibling::*)
				                                and not(following-sibling::tei:cell[@role eq 'label']))
				                           then 'row'
				                       else if ($is-header)
				                           then 'col' else ()"/>
			</xsl:where-populated>
			<xsl:apply-templates/>
			<xsl:call-template name="render-transpose-end-mark"/>
		</xsl:element>
	</xsl:template>


	<xsl:template match="tei:pb">
		<xsl:element name="{
			if ((preceding-sibling::* | following-sibling::*)[
			    self::tei:p or self::tei:head or self::tei:lg or self::tei:div
			    or self::tei:table or self::tei:list or self::tei:milestone
			    or self::tei:quote[@type eq 'block']])
			then 'div' else 'span'
		}">
			<xsl:call-template name="set-attr-from-xml-id"/>
			<xsl:call-template name="set-class-attr">
				<xsl:with-param name="class-names"
				                select="('pb',
				                         @type,
				                         if (@type eq 'author'
				                             or @type eq 'facs'
				                             or @type eq 'other'
				                             or not(@type))
				                             then 'orig' else ())"/>
			</xsl:call-template>
			<xsl:attribute name="role">doc-pagebreak</xsl:attribute>
			<xsl:variable name="delimiter"
			              select="if (empty(@subtype)) then '|' else '['"/>
			<xsl:text>{$delimiter}{@n}{if ($delimiter eq '|')
			                               then '|' else ']'}</xsl:text>
		</xsl:element>
	</xsl:template>


	<xsl:template match="tei:lb">
		<br/>
	</xsl:template>


	<xsl:template match="tei:milestone">
		<xsl:choose>
			<xsl:when test="@type">
				<hr class="milestone {@type}"/>
			</xsl:when>
			<xsl:when test="@unit eq 'part' and (@when or @source)">
				<div class="milestone milestonePart">
					<xsl:variable name="milestone-date" as="xs:string?"
					              select="slsFn:format-date-or-year(@when)"/>
					<xsl:variable name="milestone-source" as="xs:string?"
						select="slsFn:decode-uri-encoded-colons(@source)"/>
					<xsl:text>Publicerad{if ($milestone-source) then ' i ' || $milestone-source else ''}{if ($milestone-date) then ' ' || $milestone-date else ''}</xsl:text>
				</div>
			</xsl:when>
			<xsl:otherwise>
				<hr class="milestone blank"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template match="tei:note">
		<xsl:if test="@place and @xml:id">
			<xsl:variable name="in-addspan" select="slsFn:is-in-addspan(.)"/>
	    	<xsl:variable name="in-delspan" select="slsFn:is-in-delspan(.)"/>
			<xsl:variable name="addspan-hand-attr"
			              select="preceding::tei:addSpan[1]/@hand"/>
			<xsl:variable name="delspan-hand-attr"
			              select="preceding::tei:delSpan[1]/@hand"/>

			<span tabindex="0" role="doc-noteref">
				<xsl:call-template name="set-attr-from-xml-id"/>
				<xsl:call-template name="set-attr-from-xml-lang"/>
				<xsl:call-template name="set-class-attr">
					<xsl:with-param name="class-names"
						select="('footnoteindicator tooltiptrigger ttFoot',
						         @xml:id,
		                         if ($in-addspan)
			                         then (if ($addspan-hand-attr)
			                                   then 'addSpanHand'
			                               else 'addSpan')
			                     else (),
			                     if ($in-delspan)
			                         then (if ($delspan-hand-attr)
			                                   then 'delSpanHand'
			                               else 'delSpan')
			                     else ())"/>
				</xsl:call-template>
				<xsl:text>{@n}</xsl:text>
			</span>
			<span class="tooltip ttFoot" hidden="">
				<span class="tei ttFixed">
					<xsl:call-template name="set-attr-from-xml-id"/>
					<xsl:call-template name="apply-templates-with-spanning-markup"/>
				</span>
			</span>
		</xsl:if>
	</xsl:template>


	<xsl:template match="tei:figure">
		<xsl:choose>
			<xsl:when test="@type eq 'placeholder'">
				<!-- TODO: implement placeholder figure -->
			</xsl:when>
		</xsl:choose>
		<figure>
			<xsl:call-template name="set-attr-from-xml-id"/>
			<xsl:apply-templates/>
		</figure>
	</xsl:template>


	<xsl:template match="tei:head[parent::tei:figure]">
		<figcaption>
			<xsl:call-template name="set-class-attr-from-rend"/>
			<xsl:call-template name="apply-templates-with-spanning-markup"/>
		</figcaption>
	</xsl:template>


	<xsl:template match="tei:graphic">
		<xsl:if test="not(parent::tei:figure[@type eq 'placeholder'])">
			<xsl:variable name="fig-desc"
		                  select="parent::tei:figure/tei:figDesc"/>
			<img src="{@url}" loading="lazy" alt="{if ($fig-desc)
			                                           then string($fig-desc)
			                                       else 'illustration'}">
				<xsl:where-populated>
					<xsl:attribute name="height"
						select="translate(@height, 'px', '')"/>
				</xsl:where-populated>
				<xsl:where-populated>
					<xsl:attribute name="width"
						select="translate(@width, 'px', '')"/>
				</xsl:where-populated>
			</img>
		</xsl:if>
	</xsl:template>


	<!-- * <figDesc> is handled by the template for <graphic>. * -->
	<xsl:template match="tei:figDesc"/>


	<xsl:template match="tei:ptr[@type eq 'mediaCollection']">
		<a class="xreference ref_illustration" rel="nofollow"
		   href="{if (starts-with(@target, '#'))
		              then @target
		          else '#' || @target}">
			<img class="symbol" src="{$icons-base-path}/image_symbol.svg"
			     alt="illustration" loading="lazy"/>
		</a>
	</xsl:template>


	<xsl:template match="tei:date">
		<xsl:choose>
			<xsl:when test="@rend">
				<span>
					<xsl:call-template name="set-class-attr-from-rend"/>
					<xsl:apply-templates/>
				</span>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template match="tei:foreign | tei:hi">
	<!-- * Bold, italics, subscript and superscript rend-values are transformed
	     * into their equivalent HTML elements. Other rend-values become class
	     * names on a <span>. The @lang attribute is applied to the innermost
	     * element. <hi> without @rend is equivalent to a rend value of
	     * italics. * -->
		<xsl:variable name="has-element" as="xs:string*"
		              select="('bold', 'italics', 'subscript', 'superscript')"/>
		<xsl:variable name="rend-values" as="xs:string*"
		              select="normalize-space(@rend) => tokenize()"/>
		<xsl:variable name="to-elements" as="xs:string*"
		              select="$rend-values[. = $has-element]"/>
		<xsl:variable name="other-rend-values" as="xs:string*"
			select="$rend-values[not(. = $has-element)]"/>
		<xsl:variable name="xml-lang" select="@xml:lang" as="xs:string?"/>

		<!-- * Dynamically generate the correct wrapping sequence, which can
		     * contain the element names 'sub', 'sup', 'span', 'i' and 'b'.
		     * These are applied in this order, so 'sub' is the innermost
		     * element and 'b' the outermost. * -->
		<xsl:variable name="wrappers" select="(
			if ('subscript' = $to-elements) then 'sub' else (),
			if ('superscript' = $to-elements) then 'sup' else (),
			if (exists($other-rend-values)
			    or ($xml-lang and empty($to-elements)))
			    then 'span' else (),
			if ('italics' = $to-elements
			    or local-name() eq 'hi' and empty($rend-values))
			    then 'i' else (),
			if ('bold' = $to-elements) then 'b' else ()
		)"/>

		<xsl:iterate select="$wrappers">
			<xsl:param name="content">
				<xsl:apply-templates/>
			</xsl:param>
			<xsl:on-completion>
				<xsl:sequence select="$content"/>
			</xsl:on-completion>

			<xsl:variable name="wrapped-content">
				<xsl:element name="{.}">
					<!-- * Apply @lang only to the first (innermost) element * -->
					<xsl:if test="$xml-lang and position() lt 2">
						<xsl:attribute name="lang" select="$xml-lang"/>
					</xsl:if>
					<!-- * Add @class only if it's a <span> * -->
					<xsl:if test=". eq 'span' and exists($other-rend-values)">
						<xsl:attribute name="class" select="$other-rend-values"/>
					</xsl:if>
					<xsl:sequence select="$content"/>
				</xsl:element>
			</xsl:variable>

			<xsl:next-iteration>
				<xsl:with-param name="content" select="$wrapped-content"/>
			</xsl:next-iteration>
		</xsl:iterate>
	</xsl:template>


	<xsl:template match="tei:persName | tei:placeName | tei:rs | tei:title">
		<span>
			<xsl:call-template name="set-class-attr">
				<xsl:with-param name="class-names"
				                select="('tooltiptrigger',
				                         if (local-name() eq 'placeName')
				                             then 'placeName ttPlace'
				                         else if (local-name() eq 'title')
				                             then 'title ttTitle'
				                         else 'person ttPerson',
				                         @rend,
				                         if (@cert eq 'low')
				                             then 'uncertain' else (),
				                         if (@role eq 'fictional')
				                             then 'fictional' else ())"/>
			</xsl:call-template>
			<xsl:call-template name="set-attr-from-key"/>
			<xsl:call-template name="set-attr-from-xml-lang"/>
			<xsl:apply-templates/>
		</span>
	</xsl:template>


	<xsl:template match="tei:ref | tei:ptr[not(@type)]">
	<!-- TODO: Hyperlinks should only used for navigation to real URLs.
	     Should be using a <button> when not navigating to a URL. -->
		<a>
			<xsl:call-template name="set-class-attr">
				<xsl:with-param name="class-names"
				                select="('xreference',
				                         if (not(@type) or @type eq 'url')
				                             then 'ref_external'
				                         else 'ref_' || @type)"/>
			</xsl:call-template>
			<xsl:attribute name="href" select="@target"/>
			<xsl:if test="@type and @type ne 'url'">
				<xsl:attribute name="rel" select="'nofollow'"/>
			</xsl:if>
			<xsl:choose>
				<xsl:when test="local-name() eq 'ref'">
					<xsl:apply-templates/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>{@target}</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</a>
	</xsl:template>


	<xsl:template match="tei:anchor">
		<xsl:variable name="anchor-id" select="'#' || @xml:id"/>
		<xsl:variable name="matching-addspan"
		              select="//tei:addSpan[@spanTo eq $anchor-id][1]"/>
		<xsl:variable name="matching-delspan"
		              select="//tei:delSpan[@spanTo eq $anchor-id][1]"/>

		<xsl:call-template name="render-margin-add-symbol">
			<xsl:with-param name="place" select="$matching-addspan/@place"/>
		</xsl:call-template>

		<!-- * If the immediate following sibling is not another <anchor> element
		     * and the current <anchor> is an anchor for <addSpan> or <delSpan>,
		     * output a line break. * -->
		<xsl:if test="not(following-sibling::*[1][self::tei:anchor])
		              and ($matching-addspan or $matching-delspan)">
			<br/>
		</xsl:if>
	</xsl:template>


	<xsl:template match="tei:unclear">
	<!-- * If @reason is 'overstrike' or 'overwritten' show as deleted. * -->
		<xsl:variable name="reason" as="xs:string"
			select="if (not(@reason) and parent::tei:del[parent::tei:subst])
		                then 'overwritten'
		            else if (not(@reason))
		                then 'writing'
		            else @reason"/>
		<span>
			<xsl:call-template name="set-class-attr">
				<xsl:with-param name="class-names"
				                select="('unclear tooltiptrigger ttMs',
				                        if ($reason eq 'overstrike'
				                            or $reason eq 'overwritten')
				                            then 'deletion' else (),
				                        if (@hand) then 'hand' else ())"/>
			</xsl:call-template>
			<xsl:apply-templates/>
		</span>
		<span class="tooltip" hidden="">
			<xsl:text>svårtytt, orsak: {slsFn:get-reason-text($reason)}</xsl:text>
			<xsl:if test="@hand">
				<br/>
				<xsl:text>{slsFn:get-hand-text(root(), @hand)}</xsl:text>
			</xsl:if>
		</span>
	</xsl:template>


	<xsl:template match="tei:gap | tei:space">
		<xsl:call-template name="add-gap-space-content">
			<xsl:with-param name="text-type" select="'ms_changes'"/>
			<xsl:with-param name="hand-tooltip-text"
			                select="slsFn:get-hand-text(root(), @hand)"/>
		</xsl:call-template>
	</xsl:template>


	<xsl:template match="tei:del">
		<xsl:variable name="nested-del" as="element(tei:del)?"
		              select="parent::tei:del"/>
		<span>
			<xsl:call-template name="set-class-attr">
				<xsl:with-param name="class-names"
				                select="('deletion',
				                         if (parent::tei:subst)
				                             then 'substDel' else (),
				                         if (@hand)
				                             then 'hand tooltiptrigger ttMs'
				                         else ())"/>
			</xsl:call-template>
			<xsl:call-template name="render-hand-symbol"/>
			<xsl:if test="$nested-del">
				<span class="editorial-hi">[</span>
			</xsl:if>
			<xsl:apply-templates/>
			<xsl:if test="$nested-del">
				<span class="editorial-hi">]</span>
			</xsl:if>
		</span>
	</xsl:template>


	<xsl:template match="tei:metamark">
		<xsl:if test="@function eq 'instruction'">
			<span class="reading-instruction">
				<xsl:call-template name="apply-templates-with-spanning-markup"/>
			</span>
		</xsl:if>
	</xsl:template>


	<xsl:template match="tei:seg">
		<xsl:choose>
			<xsl:when test="@type eq 'alt'">
				<span class="altSeg">
					<span class="altInline">
						<xsl:apply-templates select="node() except tei:add[@type eq 'choice']"/>
					</span>
					<span class="altChoice">
						<xsl:apply-templates select="tei:add[@type eq 'choice']"/>
					</span>
					<xsl:call-template name="render-transpose-end-mark"/>
				</span>
			</xsl:when>
			<xsl:when test="@rend">
				<span class="{@rend}">
					<xsl:apply-templates/>
					<xsl:call-template name="render-transpose-end-mark"/>
				</span>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates/>
				<xsl:call-template name="render-transpose-end-mark"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template match="tei:supplied">
	<!-- * Supplied as editorial changes (have @reason) are stripped,
	     * supplied because unreadable but the context makes the content
	     * clear is shown in brackets. * -->
		<xsl:if test="@reason">
			<xsl:text>[</xsl:text>
			<xsl:apply-templates/>
			<xsl:text>]</xsl:text>
		</xsl:if>
	</xsl:template>


	<xsl:template match="tei:reg">
		<xsl:if test="not(parent::tei:choice)">
			<xsl:apply-templates/>
		</xsl:if>
	</xsl:template>


	<xsl:template match="tei:expan | tei:rdg"/>


	<xsl:template match="tei:add">
		<xsl:variable name="nested-add" as="element(tei:add)?"
		              select="parent::tei:add"/>
		
		<span>
			<xsl:call-template name="set-class-attr">
				<xsl:with-param name="class-names"
				                select="(if (parent::tei:subst)
				                             then 'substAdd' else (),
				                         if (@hand) then 'hand tooltiptrigger ttMs' else (),
				                         if (@type eq 'choice')
				                             then 'choiceAdd'
				                         else if (@place eq 'botMargin'
				                             or @place eq 'leftMargin'
				                             or @place eq 'rightMargin'
				                             or @place eq 'topMargin')
				                             then 'addMargin'
				                         else if (@place eq 'sublinear')
				                             then 'addSublinear'
				                         else if (@place eq 'inline')
				                             then 'addInline'
				                         else if (parent::tei:add
				                                  and not(parent::tei:add[@place eq 'inline']))
				                             then 'addInAdd'
				                         else 'addOver')"/>
			</xsl:call-template>
			<xsl:call-template name="render-hand-symbol"/>
			<xsl:call-template name="render-no-anchor-symbol"/>
			<xsl:call-template name="render-margin-add-symbol"/>
			<xsl:if test="$nested-add">
				<!-- &#92; is rendered as a forward slash: \ -->
				<span class="editorial-hi">&#92;</span>
			</xsl:if>
			<xsl:apply-templates/>
			<xsl:if test="$nested-add">
				<span class="editorial-hi">/</span>
			</xsl:if>
			<xsl:call-template name="render-margin-add-symbol"/>
		</span>
	</xsl:template>


	<xsl:template match="tei:addSpan">
		<xsl:call-template name="render-hand-symbol"/>
		<xsl:call-template name="render-no-anchor-symbol"/>
		<xsl:call-template name="render-margin-add-symbol"/>
	</xsl:template>


	<xsl:template match="tei:delSpan">
		<xsl:call-template name="render-hand-symbol"/>
	</xsl:template>


	<xsl:template match="tei:subst">
		<xsl:call-template name="render-hand-symbol"/>
		<span class="editorial-hi">|</span>
		<span class="subst">
			<xsl:apply-templates/>
		</span>
		<span class="editorial-hi">|</span>
	</xsl:template>


	<xsl:template match="tei:restore">
		<span class="restore">
			<xsl:call-template name="render-hand-symbol"/>
			<xsl:apply-templates/>
		</span>
	</xsl:template>


	<xsl:template match="tei:handShift">
		<xsl:call-template name="render-hand-symbol"/>
	</xsl:template>


	<xsl:template match="tei:metamark[@function eq 'transp']">
		<span class="transpMark">
			<xsl:text>{@n}</xsl:text>
		</span>
		<span class="editorial-hi">|</span>
	</xsl:template>



	<!-- * NAMED TEMPLATES ******************************************** -->

	<xsl:template name="apply-templates-with-spanning-markup">
	<!-- * This template is a drop-in replacement for xsl:apply-templates,
	     * used when rendering TEI content that may be part of a change
	     * span (i.e., <addSpan> or <delSpan> with a corresponding
	     * <anchor>).
	     *
	     * It detects whether the context node falls within an active
	     * addSpan or delSpan range (based on preceding:: and following::
	     * checks) and, if so, wraps the output in one or more <span>
	     * elements with appropriate class names to indicate additions or
	     * deletions in the manuscript. It also renders tooltips when @hand
	     * attributes are present on the span elements.
	     *
	     * Usage:
	     * Use this template instead of plain xsl:apply-templates whenever
	     * the output should reflect manuscript changes marked using
	     * <addSpan> or <delSpan> in the TEI source.
	     *
	     * Notes:
	     * - This logic assumes that <addSpan> may contain <delSpan>, but
	     *   not the reverse.
	     * - Span wrappers are inserted only if the context node is within
	     *   a detected span range.
	     * - The tooltip rendering relies on a separate render-hand-tooltip
	     *   template and the presence of matching <handNote> entries in
	     * the TEI header. * -->
		<xsl:variable name="in-addspan" select="slsFn:is-in-addspan(.)"/>
    	<xsl:variable name="in-delspan" select="slsFn:is-in-delspan(.)"/>

		<!-- Case: Either addSpan or delSpan -->
		<xsl:if test="$in-addspan or $in-delspan">
			<xsl:variable name="addspan-hand-attr"
			              select="preceding::tei:addSpan[1]/@hand"/>
			<xsl:variable name="delspan-hand-attr"
			              select="preceding::tei:delSpan[1]/@hand"/>

			<span>
				<xsl:call-template name="set-class-attr">
					<xsl:with-param name="class-names"
					                select="(if ($in-addspan)
					                             then (if ($addspan-hand-attr)
					                                       then 'addSpanHand'
					                                   else 'addSpan')
					                         else (),
					                         if ($in-delspan)
					                             then (if ($delspan-hand-attr)
					                                       then 'delSpanHand'
					                                   else 'delSpan')
					                         else ())"/>
				</xsl:call-template>
				<xsl:apply-templates/>
				<xsl:call-template name="render-transpose-end-mark"/>
			</span>
		</xsl:if>

		<!-- Case: Neither addSpan nor delSpan -->
		<xsl:if test="not($in-addspan) and not($in-delspan)">
			<xsl:apply-templates/>
			<xsl:call-template name="render-transpose-end-mark"/>
		</xsl:if>
	</xsl:template>


	<xsl:template name="render-hand-symbol">
		<xsl:if test="@hand or @new or @medium">
			<xsl:variable name="level" select="if (local-name(.) eq 'addSpan'
				                                   or local-name(.) eq 'delSpan')
				                                   then 'block'
				                               else 'inline'"/>
			<img src="assets/images/hand.svg"
			     class="tooltiptrigger ttMs handSymbol {$level}Symbol{if (local-name(.) eq 'delSpan') then ' delSpan' else ''}"
			     alt="byte av hand eller penna"
			     loading="lazy"/>
			<xsl:call-template name="render-hand-tooltip">
				<xsl:with-param name="hand-attr" select="if (@hand)
				                                             then @hand
				                                         else if (@new)
				                                             then @new
				                                         else ()"/>
				<xsl:with-param name="level" select="$level"/>
				<xsl:with-param name="medium-attr"
				                select="if (@medium)
				                            then @medium else ()"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>


	<xsl:template name="render-hand-tooltip">
		<xsl:param name="hand-attr" as="xs:string?" select="()"/>
		<xsl:param name="level" as="xs:string" select="'block'"/>
		<xsl:param name="medium-attr" as="xs:string?" select="()"/>

		<xsl:variable name="hand-text" as="xs:string?"
		              select="if ($hand-attr)
		                          then slsFn:get-hand-text(root(), $hand-attr)
		                      else if ($medium-attr)
		                          then map:get($medium-map, $medium-attr)
		                      else ()"/>
		<xsl:if test="$hand-text">
			<xsl:variable name="element-name" as="xs:string"
			              select="if ($level eq 'block')
			                          then 'div'
			                      else 'span'"/>
			<xsl:element name="{$element-name}">
				<xsl:attribute name="class" select="'tooltip'"/>
				<xsl:attribute name="hidden" select="''"/>
				<xsl:text>{$hand-text}</xsl:text>
				<xsl:if test="local-name() eq 'add'">
					<xsl:text> (tillagt)</xsl:text>
				</xsl:if>
				<xsl:if test="local-name() eq 'del'">
					<xsl:text> (struket)</xsl:text>
				</xsl:if>
				<xsl:if test="local-name() eq 'subst'">
					<xsl:text> (ersatt)</xsl:text>
				</xsl:if>
				<xsl:if test="local-name() eq 'addSpan'">
					<xsl:text> (tillagt parti)</xsl:text>
				</xsl:if>
				<xsl:if test="local-name() eq 'delSpan'">
					<xsl:text> (struket parti)</xsl:text>
				</xsl:if>
				<xsl:if test="local-name() eq 'restore'">
					<xsl:text> (återtagen ändring)</xsl:text>
				</xsl:if>
			</xsl:element>
		</xsl:if>
	</xsl:template>


	<xsl:template name="render-no-anchor-symbol">
		<xsl:if test="@type eq 'noAnchor'">
			<span class="editorial-hi">
				<xsl:text>&#936;?</xsl:text>
			</span>
		</xsl:if>
	</xsl:template>


	<xsl:template name="render-margin-add-symbol">
		<xsl:param name="place" as="xs:string?" select="()"/>

		<xsl:choose>
			<xsl:when test="@place eq 'leftMargin' or $place eq 'leftMargin'">
				<img src="assets/images/ms_arrow_left.svg"
				     alt="marginaltillägg vänster"
				     class="addMarginSymbol"
				     loading="lazy"/>
			</xsl:when>
			<xsl:when test="@place eq 'rightMargin' or $place eq 'rightMargin'">
				<img src="assets/images/ms_arrow_right.svg"
				     alt="marginaltillägg höger"
				     class="addMarginSymbol"
				     loading="lazy"/>
			</xsl:when>
			<xsl:when test="@place eq 'topMargin' or $place eq 'topMargin'">
				<img src="assets/images/ms_arrow_up.svg"
				     alt="marginaltillägg uppe"
				     class="addMarginSymbol"
				     loading="lazy"/>
			</xsl:when>
			<xsl:when test="@place eq 'botMargin' or $place eq 'botMargin'">
				<img src="assets/images/ms_arrow_down.svg"
				     alt="marginaltillägg nere"
				     class="addMarginSymbol"
				     loading="lazy"/>
			</xsl:when>
		</xsl:choose>
	</xsl:template>


	<xsl:template name="render-transpose-end-mark">
		<xsl:if test="tei:metamark[@function eq 'transp']">
			<span class="editorial-hi">|</span>
		</xsl:if>
	</xsl:template>


	<!-- * FUNCTIONS ************************************************** -->

	<xsl:function name="slsFn:get-hand-text" as="xs:string?" cache="yes">
	<!-- * Extracts information about the author and medium from a
	     * <handNote> element matched by the given hand-id, and returns
	     * the information as a string in Swedish. The function maps
	     * predefined medium codes (e.g., "black-ink", "green-pen",
	     * "pencil") to corresponding descriptions. * -->
		<xsl:param name="doc" as="document-node()"/>
		<xsl:param name="hand-id" as="xs:string?"/>

		<xsl:if test="not($hand-id)">
			<xsl:sequence select="()"/>
		</xsl:if>
		
		<xsl:variable name="handnote" as="element(tei:handNote)?" select="$doc/tei:TEI/tei:teiHeader/tei:profileDesc/tei:handNotes/tei:handNote[('#' || @xml:id) eq $hand-id]"/>

		<xsl:variable name="author-text" as="xs:string"
		              select="normalize-space(string($handnote))"/>

		<xsl:variable name="medium-attr" as="xs:string?"
		              select="$handnote/@medium"/>

		<xsl:variable name="medium-text" as="xs:string?"
                      select="if ($medium-attr and map:contains($medium-map, $medium-attr))
                                  then map:get($medium-map, $medium-attr)
                              else ()"/>
		
		<xsl:sequence select="if (not($author-text eq '') and $medium-text)
		                          then $author-text || ': ' || $medium-text
		                      else if (not($author-text eq '') and empty($medium-text))
		                          then $author-text
		                      else if ($medium-text)
		                          then $medium-text
		                      else ()"/>
	</xsl:function>


	<xsl:function name="slsFn:is-in-addspan" as="xs:boolean">
	<!-- * Returns true if the passed element is within an addSpan,
	     * otherwise false. * -->
		<xsl:param name="current" as="node()"/>

		<xsl:variable name="preceding-add-spans"
		              select="$current/preceding::tei:addSpan"/>
		<xsl:variable name="add-span-ids"
		              select="for $span in $preceding-add-spans
		                      return $span/@spanTo"/>
		<xsl:sequence select="some $id in $add-span-ids
		                      satisfies $current/following::tei:anchor[('#' || @xml:id) eq $id]"/>
	</xsl:function>


	<xsl:function name="slsFn:is-in-delspan" as="xs:boolean">
	<!-- * Returns true if the passed element is within a delSpan,
	     * otherwise false. * -->
		<xsl:param name="current" as="node()"/>

		<xsl:variable name="preceding-del-spans"
		              select="$current/preceding::tei:delSpan"/>
		<xsl:variable name="del-span-ids"
		              select="for $span in $preceding-del-spans
		                      return $span/@spanTo"/>
		<xsl:sequence select="some $id in $del-span-ids
		                      satisfies $current/following::tei:anchor[('#' || @xml:id) eq $id]"/>
	</xsl:function>

</xsl:stylesheet>