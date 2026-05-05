<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:map="http://www.w3.org/2005/xpath-functions/map"
	xmlns:array="http://www.w3.org/2005/xpath-functions/array"
	xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns:slsEdData="https://www.sls.fi/ns/digitaledition/metadata/"
	xmlns:slsFn="https://www.sls.fi/ns/digitaledition/functions/"
	exclude-result-prefixes="#all"
	expand-text="yes"
>

	<!-- ******************************************************************
	*
	*    XSLT stylesheet: publication-metadata.xsl
	*    Version: 1.0.0
	*    Author:  Sebastian Köhler, Svenska litteratursällskapet i Finland,
	*             https://www.sls.fi/
	*    Created: 2026-05-04
	*    Licence: CC-BY 4.0 (Attribution 4.0 International),
	*             https://creativecommons.org/licenses/by-nc/4.0/
	*
	*    Changes:
	*        v1.0.0 (2026-05-04)
	*
	*    Description:
	*        This XSLT document creates publication-level metadata as JSON.
	*        It combines metadata supplied by the calling application with
	*        metadata read from referenced TEI XML documents, normalises selected
	*        values, and emits a compact metadata object for downstream use.
	*
	*    Usage:
	*        Set the db-json input parameter on the XSLT processor and run the
	*        stylesheet with its initial template. No primary source document is
	*        required; XML documents are loaded from URI values in the input
	*        metadata when available.
	*
	*    Input parameters:
	*        - db-json (xs:string?, required): A JSON object serialised as a
	*          string. The object is parsed with parse-json() and is expected to
	*          contain publication metadata from the database.
	*
	*          Expected top-level shape:
	*
	*              {
	*                  "metadata_language": "...",
	*                  "publication_id": "...",
	*                  "publication_title": "...",
	*                  "publication_date": "...",
	*                  "publication_genre": "...",
	*                  "publication_language": "...",
	*                  "publication_filepath": "...",
	*                  "publication_filepath_uri": "...",
	*                  "comment_filepath": "...",
	*                  "comment_filepath_uri": "...",
	*                  "collection_id": "...",
	*                  "collection_title": "...",
	*                  "manuscripts": [ ... ],
	*                  "variants": [ ... ],
	*                  "facsimiles": [ ... ]
	*              }
	*
	*          The manuscripts array contains objects with manuscript metadata,
	*          including id, title, original_filename, original_filename_uri,
	*          section_id, sort_order and language.
	*
	*          The variants array contains objects with variant metadata,
	*          including id, title, original_filename, original_filename_uri,
	*          section_id, sort_order and type.
	*
	*          The facsimiles array contains objects with facsimile metadata,
	*          including id, facs_coll_id, publication_manuscript_id,
	*          publication_variant_id, title, section_id, priority, page_nr,
	*          number_of_images, description and external_url.
	*
	*    Output:
	*        A JSON object containing normalised publication metadata.
	*
	******************************************************************* -->


	<!-- * SERIALIZATION OPTIONS ************************************** -->

	<xsl:output method="json" encoding="UTF-8" indent="yes"
	            json-node-output-method="text"/>



	<!-- * IMPORTS **************************************************** -->

	<xsl:import href="shared-date-functions.xsl"/>
	<xsl:import href="shared-language-functions.xsl"/>
	<xsl:import href="shared-tei-to-html-string-functions.xsl"/>



	<!-- * PARAMETERS *****************************************************
	     * Declare input parameters. * -->

	<xsl:param name="db-json" as="xs:string?" select="()"/>



	<!-- * GLOBAL VARIABLES ******************************************* -->

	<!-- * The JSON text metadata from the database parsed into a map. * -->
	<xsl:variable name="db-meta" as="map(*)" select="parse-json($db-json)"/>

	<!-- * Target language of the metadata, i.e. the language the output
		 * metadata should be in. * -->
	<xsl:variable name="meta-lang" as="xs:string"
		          select="slsFn:normalise-language($db-meta?metadata_language)"/>



	<!-- * TEMPLATES ************************************************** -->

	<!-- * Entry point: initial template. * -->
	<xsl:template name="xsl:initial-template">
		<!-- * Number of facsimiles. * -->
		<xsl:variable name="facs-count" as="xs:integer"
			          select="count($db-meta?facsimiles?*)"/>

		<!-- * Number of manuscripts. * -->
		<xsl:variable name="ms-count" as="xs:integer"
			          select="count($db-meta?manuscripts?*)"/>

		<!-- * Boolean which is true if the publication has a publication_filepath,
			 * i.e. a reading text XML file. * -->
		<xsl:variable name="has-readingtext" as="xs:boolean"
		              select="boolean(normalize-space($db-meta?publication_filepath))"/>

		<!-- * Boolean which is true if the publication consists of only
			 * one manuscript, which is set as the reading text, or there
			 * is no reading text. * -->
		<xsl:variable name="single-ms-publication" as="xs:boolean"
		              select="let $first-ms-filepath := 
		                          if ($ms-count gt 0)
		                              then $db-meta?manuscripts?1?original_filename_uri
		                          else ()
		                      return
		                      $ms-count eq 1 and
		                      exists($first-ms-filepath) and
		                      (
		                       not($has-readingtext)
		                       or
		                       $db-meta?publication_filepath_uri eq $first-ms-filepath
		                      )"/>

		<xsl:variable name="main-doc" as="document-node()?"
		              select="if ($single-ms-publication)
		                          then slsFn:doc-if-available($db-meta?manuscripts?1?original_filename_uri)
		                      else (
		                          let $publication-file := slsFn:doc-if-available($db-meta?publication_filepath_uri)
		                          return
		                          if (exists($publication-file))
		                              then $publication-file
		                          else if ($ms-count gt 1)
		                              then slsFn:doc-if-available($db-meta?manuscripts?1?original_filename_uri)
		                          else ()
		                      )"/>

		<xsl:variable name="publication-title" as="xs:string"
		              select="let $norm-publ-title := normalize-space($db-meta?publication_title)
		                      return
		                      if ($norm-publ-title)
						          then $norm-publ-title
						      else if ($single-ms-publication)
						          then normalize-space($db-meta?manuscripts?1?title)
						      else if ($meta-lang eq 'en')
						          then 'unknown title'
						      else 'okänd titel'"/>

		<xsl:variable name="publication-language" as="xs:string?"
		              select="let $lang-code:= slsFn:normalise-language(
		                                           ($db-meta?publication_language,
		                                            $main-doc/tei:TEI/tei:text/@xml:lang)[1]
		                                       )
		                      return slsFn:language-name($lang-code, $meta-lang)"/>

		<xsl:variable name="author" as="array(xs:string)"
		              select="array {
		                             for $a in $main-doc/tei:TEI/tei:teiHeader/tei:fileDesc
		                                 /tei:titleStmt/tei:author
		                             return normalize-space(string($a))
		                            }"/>

		<xsl:variable name="orig-date" as="xs:string?"
		              select="($main-doc/tei:TEI/tei:teiHeader/tei:fileDesc
		                           /tei:sourceDesc//tei:origDate[@when]/@when,
		                       $main-doc/tei:TEI/tei:teiHeader/tei:fileDesc
		                           /tei:sourceDesc//tei:date[1][@when]/@when,
		                       $main-doc/tei:TEI/tei:teiHeader/tei:profileDesc
		                           /tei:correspDesc/tei:correspAction[@type eq 'sent']
		                           /tei:date[@when]/@when,
		                       normalize-space($db-meta?publication_date))[1]"/>

		<xsl:variable name="publication-date" as="xs:string?"
		              select="slsFn:format-w3c-date($orig-date,
				                                    $meta-lang)"/>

		<xsl:variable name="keywords-elem" as="element(tei:keywords)?"
		              select="$main-doc/tei:TEI/tei:teiHeader/tei:profileDesc
		                      /tei:textClass/tei:keywords"/>

		<xsl:variable name="publication-genre" as="xs:string?"
		              select="let $genre := ($keywords-elem/tei:term[@type eq 'genre'][@xml:lang eq $meta-lang],
		                                     $keywords-elem/tei:term[@type eq 'genre'],
		                                     $db-meta?publication_genre)[1]
		                      return
		                      if (exists($genre))
		                          then string($genre) => normalize-space() => lower-case()
		                      else ()"/>

		<xsl:variable name="keywords" as="xs:string?"
		              select="let $lang-terms := $keywords-elem/tei:term[not(@type eq 'genre')][@xml:lang eq $meta-lang],
		                          $terms := if (exists($lang-terms))
		                                        then $lang-terms
		                                    else $keywords-elem/tei:term[not(@type eq 'genre')]
		                      return
		                      if (exists($terms))
		                          then $terms ! normalize-space(.)
		                               ! lower-case(.)
		                               => sort('http://www.w3.org/2013/collation/UCA?lang=sv')
		                               => string-join(', ')
		                      else ()"/>

		<xsl:variable name="sender" as="array(xs:string)"
		              select="array {
			                      for $s in $main-doc/tei:TEI/tei:teiHeader/tei:profileDesc
			                          /tei:correspDesc/tei:correspAction[@type eq 'sent']
			                          //tei:persName
			                      return normalize-space(string($s))
			                     }"/>

		<xsl:variable name="receiver" as="array(xs:string)"
		              select="array {
			                      for $r in $main-doc/tei:TEI/tei:teiHeader/tei:profileDesc
			                          /tei:correspDesc/tei:correspAction[@type eq 'received']
			                          //tei:persName
			                      return normalize-space(string($r))
			                     }"/>

		<xsl:variable name="licence-elem" as="element(tei:licence)?"
		              select="($main-doc/tei:TEI/tei:teiHeader/tei:fileDesc/tei:publicationStmt
			                           /tei:availability/tei:licence[@xml:lang eq $meta-lang][1],
			                   $main-doc/tei:TEI/tei:teiHeader/tei:fileDesc/tei:publicationStmt
			                           /tei:availability/tei:licence[1])[1]"/>

		<xsl:variable name="licence" as="xs:string?"
		              select="if (exists($licence-elem))
		                          then normalize-space(string($licence-elem))
		                      else ()"/>

		<xsl:variable name="licence-url" as="xs:string?"
		              select="if (exists($licence) and exists($licence-elem/@target))
		                          then $licence-elem/@target
		                      else ()"/>

		<xsl:variable name="phys-dimensions" as="xs:string?"
		              select="let $dim-elem := $main-doc/tei:TEI/tei:teiHeader/tei:fileDesc
		                               /tei:sourceDesc/tei:msDesc/tei:physDesc/tei:objectDesc
		                               /tei:supportDesc/tei:extent/tei:dimensions
		                      return
		                          if ($dim-elem and $dim-elem/tei:height and $dim-elem/tei:width)
		                              then string($dim-elem/tei:width) || ' × '
		                                   || string($dim-elem/tei:height)
		                                   || (if ($dim-elem[@unit])
		                                           then (' ' || string($dim-elem/@unit))
		                                       else '')
		                          else ()"/>

		<xsl:variable name="phys-description" as="array(xs:string)"
		              select="array {
		                          for $p in $main-doc/tei:TEI/tei:teiHeader/tei:fileDesc
		                                    /tei:sourceDesc/tei:msDesc/tei:physDesc/tei:p
		                          return normalize-space(string($p))
		                      }"/>

		<xsl:variable name="source" as="xs:string?"
		              select="let $ms-identifier := $main-doc/tei:TEI/tei:teiHeader/tei:fileDesc
		                               /tei:sourceDesc/tei:msDesc/tei:msIdentifier,
		                          $source-desc := $main-doc/tei:TEI/tei:teiHeader/tei:fileDesc
		                               /tei:sourceDesc
		                      return
		                          if (exists($ms-identifier))
		                              then (let $parts := ($ms-identifier/tei:collection,
		                                                   $ms-identifier/tei:repository,
		                                                   $ms-identifier/tei:institution,
		                                                   $ms-identifier/tei:settlement,
		                                                   $ms-identifier/tei:country,
		                                                   '”' || string($ms-identifier/tei:msName) || '”',
		                                                   $ms-identifier/tei:idno)
		                                    return
		                                        $parts ! string(.)
		                                        ! normalize-space(.)
		                                        => string-join(', '))
		                          else if (exists($source-desc/tei:bibl))
		                              then slsFn:tei-inline-html($source-desc/tei:bibl[1])
		                          else if (exists($source-desc/tei:*))
		                              then slsFn:tei-inline-html($source-desc)
		                          else ()"/>

		<xsl:map>
			<xsl:map-entry key="'id'"
				           select="$db-meta?publication_id"/>

			<xsl:map-entry key="'publication_title'"
				           select="$publication-title"/>

			<xsl:if test="$publication-date">
				<xsl:map-entry key="'publication_date'"
				               select="$publication-date"/>
			</xsl:if>

			<xsl:if test="exists($publication-language)">
				<xsl:map-entry key="'publication_language'"
				               select="$publication-language"/>
			</xsl:if>

			<xsl:if test="$publication-genre">
				<xsl:map-entry key="'publication_genre'"
				               select="$publication-genre"/>
			</xsl:if>

			<xsl:map-entry key="'collection_id'"
				           select="$db-meta?collection_id"/>

			<xsl:map-entry key="'collection_title'"
				           select="normalize-space($db-meta?collection_title)"/>

			<xsl:if test="exists($keywords)">
				<xsl:map-entry key="'keywords'"
			                   select="$keywords"/>
			</xsl:if>

			<xsl:if test="exists($licence)">
				<xsl:map-entry key="'licence'"
			                   select="$licence"/>
			</xsl:if>

			<xsl:if test="exists($licence-url)">
				<xsl:map-entry key="'licence_url'"
			                   select="$licence-url"/>
			</xsl:if>

			<xsl:if test="exists($source)">
				<xsl:map-entry key="'source'"
			                   select="$source"/>
			</xsl:if>

			<xsl:if test="$phys-dimensions">
				<xsl:map-entry key="'phys_dimensions'"
			                   select="$phys-dimensions"/>
			</xsl:if>

			<xsl:if test="array:size($phys-description) gt 0">
				<xsl:map-entry key="'phys_description'"
				               select="$phys-description"/>
			</xsl:if>

			<xsl:if test="array:size($author) gt 0 and array:size($sender) eq 0">
				<xsl:map-entry key="'author'"
				               select="$author"/>
			</xsl:if>

			<xsl:if test="array:size($sender) gt 0">
				<xsl:map-entry key="'sender'"
				               select="$sender"/>
			</xsl:if>

			<xsl:if test="array:size($receiver) gt 0">
				<xsl:map-entry key="'recipient'"
				               select="$receiver"/>
			</xsl:if>

			<xsl:if test="$single-ms-publication or $ms-count eq 1">
				<xsl:map-entry key="'manuscript_id'"
				               select="$db-meta?manuscripts?1?id"/>
			</xsl:if>
		</xsl:map>


		<!-- * This is a map of all fields in the input metadata.
			 * It should only be used as reference. *

		<xsl:map>
			<xsl:map-entry key="'id'" select="$db-meta?publication_id"/>
			<xsl:map-entry key="'publication_title'" select="$db-meta?publication_title"/>
			<xsl:map-entry key="'publication_date'" select="$db-meta?publication_date"/>
			<xsl:map-entry key="'publication_genre'" select="$db-meta?publication_genre"/>
			<xsl:map-entry key="'publication_language'" select="$db-meta?publication_language"/>
			<xsl:map-entry key="'publication_filepath'" select="$db-meta?publication_filepath"/>
			<xsl:map-entry key="'publication_filepath_uri'" select="$db-meta?publication_filepath_uri"/>
			<xsl:map-entry key="'comment_filepath'" select="$db-meta?comment_filepath"/>
			<xsl:map-entry key="'comment_filepath_uri'" select="$db-meta?comment_filepath_uri"/>
			<xsl:map-entry key="'collection_id'" select="$db-meta?collection_id"/>
			<xsl:map-entry key="'collection_title'" select="$db-meta?collection_title"/>

			<xsl:map-entry key="'manuscripts'" select="
				array {
					for $ms in $db-meta?manuscripts?*
					return
						map {
							'id': $ms?id,
							'title': $ms?title,
							'original_filename': $ms?original_filename,
							'original_filename_uri': $ms?original_filename_uri,
							'section_id': $ms?section_id,
							'sort_order': $ms?sort_order,
							'language': $ms?language
						}
				}
			"/>

			<xsl:map-entry key="'variants'" select="
				array {
					for $var in $db-meta?variants?*
					return
						map {
							'id': $var?id,
							'title': $var?title,
							'original_filename': $var?original_filename,
							'original_filename_uri': $var?original_filename_uri,
							'section_id': $var?section_id,
							'sort_order': $var?sort_order,
							'type': $var?type
						}
				}
			"/>

			<xsl:map-entry key="'facsimiles'" select="
				array {
					for $fac in $db-meta?facsimiles?*
					return
						map {
							'id': $fac?id,
							'facs_coll_id': $fac?facs_coll_id,
							'publication_manuscript_id': $fac?publication_manuscript_id,
							'publication_variant_id': $fac?publication_variant_id,
							'title': $fac?title,
							'section_id': $fac?section_id,
							'priority': $fac?priority,
							'page_nr': $fac?page_nr,
							'number_of_images': $fac?number_of_images,
							'description': $fac?description,
							'external_url': $fac?external_url
						}
				}
			"/>
			</xsl:map>
			-->
	</xsl:template>



	<!-- * FUNCTIONS ************************************************** -->

	<xsl:function name="slsFn:doc-if-available" as="document-node()?">
		<!-- * Given a file path or a file URI, returns the document if it
			 * is available, otherwise returns an empty sequence. * -->
		<xsl:param name="uri" as="xs:string?"/>
	
		<xsl:sequence select="if ($uri and doc-available($uri))
		                          then doc($uri)
		                      else ()"/>
	</xsl:function>



</xsl:stylesheet>
