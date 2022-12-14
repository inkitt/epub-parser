# -*- coding: utf-8 -*-
require_relative 'helper'

class TestParserContentDocument < Test::Unit::TestCase
  def setup
    @manifest = EPUB::Publication::Package::Manifest.new
    %w[item-1.xhtml item-2.xhtml nav.xhtml].each.with_index do |href, index|
      item = EPUB::Publication::Package::Manifest::Item.new
      item.id = index
      item.href = href
      @manifest << item
    end
    @manifest.package = Object.new
    stub(@manifest.package).full_path {"OPS/ルートファイル.opf"}

    @dir = 'test/fixtures/book'
    @parser = EPUB::Parser::ContentDocument.new(@manifest.items.last)
  end

  def test_parse_navigations
    doc = Nokogiri.XML open("#{@dir}/OPS/nav.xhtml")
    navs = @parser.parse_navigations doc
    nav = navs.first

    assert_equal 2, navs.length
    assert_equal 'Table of Contents', nav.heading
    assert_equal 'toc', nav.type
    assert_equal Set.new(["toc"]), nav.types

    assert_equal 2, nav.items.length
    assert_equal @manifest.items.first, nav.items.first.item
    assert_equal @manifest.items[1], nav.items[1].items[0].item
    assert_equal @manifest.items[1], nav.items[1].items[1].item

    assert_equal '第四節', nav.items.last.items.last.text

    assert_true nav.hidden?
  end

  def test_landmarks
    epub = EPUB::Parser.parse("#{@dir}.epub")
    manifest = epub.manifest
    landmarks = epub.nav.content_document.landmarks

    assert_equal "Guide", landmarks.heading
    assert_equal "landmarks", landmarks.type
    assert_equal Set.new(["landmarks"]), landmarks.types

    assert_equal 2, landmarks.items.length

    assert_equal manifest["nav"], landmarks.items.first.item
    assert_equal manifest["japanese-filename"], landmarks.items[1].item

    assert_equal "Body", landmarks.items.last.text
    assert_equal "bodymatter", landmarks.items.last.types.first
  end
end
