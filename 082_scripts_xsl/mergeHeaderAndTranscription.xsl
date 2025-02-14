<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs tei"
    version="2.0">
    <xsl:output method="xml" indent="yes"/>
    
    <!--  
        This stylesheet merges the metadata from the Corpus document and the 
        TEI-represenation of the ELAN transcriptions. 
        
        TODOs mentioned inline.
        
        Author: Daniel Schopper
        Created: 2022-03-12
    -->
    
    <xsl:param name="pathToCorpusDoc"/>
    <xsl:variable name="input" select="."/>
    <xsl:variable name="corpusDoc" select="doc($pathToCorpusDoc)" as="document-node()"/>
    <xsl:variable name="IDcandidates" select="$corpusDoc//*:title"/>
    <xsl:variable name="pathSegs" select="tokenize(base-uri($input),'/')"/>
    <xsl:variable name="recordingID" select="$IDcandidates[some $x in $pathSegs satisfies contains(lower-case($x), lower-case(.))]"/>
    <xsl:variable name="teiHeaderFromCorpus" select="$recordingID/ancestor::tei:teiHeader" as="element(tei:teiHeader)?"/>
    
    <xsl:template match="/">
        <xsl:if test="normalize-space($recordingID) = ''">
            <xsl:message select="concat('$input=',base-uri($input))"/>
            <xsl:message select="concat('$pathToCorpusDoc=',$pathToCorpusDoc)"/>
            <xsl:message select="concat('$IDcandidates=',string-join($IDcandidates,', '))"/>
            <xsl:message select="concat('$recordingID=',$recordingID)"/>
            <xsl:message terminate="yes">$recordingID could not be determined from input filename <xsl:value-of select="tokenize(base-uri($input),'/')[last()]"/></xsl:message>
        </xsl:if>
        <xsl:if test="not($teiHeaderFromCorpus)">
            <xsl:message select="concat('$input=',base-uri($input))"/>
            <xsl:message select="concat('$pathToCorpusDoc=',$pathToCorpusDoc)"/>
            <xsl:message select="concat('$IDcandidates=',string-join($IDcandidates,', '))"/>
            <xsl:message select="concat('$recordingID=',$recordingID)"/>
            <xsl:message terminate="yes">teiHeader for recording <xsl:value-of select="$recordingID"/> not found in <xsl:value-of select="$pathToCorpusDoc"/></xsl:message>
        </xsl:if>
        <xsl:comment>THIS FILE WAS PROGRAMMATICALLY CREATED by mergeHeaderAndTranscription.xsl on/at<xsl:value-of select="current-dateTime()"/></xsl:comment>
        <xsl:apply-templates>
            <xsl:with-param name="teiHeaderFromCorpus" select="$teiHeaderFromCorpus" tunnel="yes"/>
        </xsl:apply-templates>
    </xsl:template>
    
    <!-- TODO: make a real merge, i.e. include relelvant metadata from the ELAN export 
        and not just overwrite it with the corpus header -->
    <xsl:template match="tei:teiHeader">
        <xsl:param name="teiHeaderFromCorpus" tunnel="yes"/>
        <xsl:sequence select="$teiHeaderFromCorpus"/>
    </xsl:template>
    
    <xsl:template match="tei:seg">
        <xsl:analyze-string select="text()" regex="[-–_. ,?!“…]">
            <xsl:matching-substring>
            <xsl:choose>
                <xsl:when test=". eq ' '"/>
                <xsl:when test=". eq '-'">
                    <pc type="ignoreInSearchIndex"><xsl:value-of select="."/></pc>
                </xsl:when>
                <xsl:otherwise>
                    <pc><xsl:value-of select="."/></pc>
                </xsl:otherwise>
            </xsl:choose>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <w><xsl:value-of select="."/></w>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>
    
    
    
</xsl:stylesheet>