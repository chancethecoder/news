require 'open-uri'
require 'rest-client'
require 'selenium-webdriver'

class ArticlesController < ApplicationController
  skip_before_action :authenticate_user!

  def scrape_nbcnews_articles_by_keyword(keyword)
    articles = []

    Selenium::WebDriver::Chrome.driver_path = `which chromedriver-helper`.chomp # 설치한 크롬 드라이버 사용

    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument('--disable-gpu')
    options.add_argument('--headless')

    # 셀레니움 + 크롬 + 헤드리스 옵션으로 브라우저 실행
    browser = Selenium::WebDriver.for :chrome, options: options

    # 검색 페이지 이동
    browser.navigate().to "https://www.nbcnews.com/search/?q=#{keyword}"

    # TODO: 페이지 별로 목록을 가져오려면 아래 부분 구현 필요
    # 페이징 목록 가져오기
    # pages = browser.find_elements(css: "div.gsc-cursor > div.gsc-cursor-page")
    # pages.each do |page|
    #   page.click
    #   sleep(2)
    # end

    # 아티클 목록 가져오기
    article_list = browser.find_elements(css: "div.gsc-result")

    article_list.each do |article_link|
      # 아티클 링크에서 타이틀, 주소 가져오기
      article = Hash.new
      article["title"] = article_link.find_element(css: "a.gs-title").text
      article["url"] = article_link.find_element(css: "a.gs-title").attribute("href")
      articles << article
    end

    articles
  end

  def scrape_politico_articles_by_keyword(keyword)
    articles = []
    # TODO: 스크래핑 구현하기
    articles
  end

  def index
    keyword = params[:keyword]
    articles = []
    articles += scrape_nbcnews_articles_by_keyword(keyword)
    articles += scrape_politico_articles_by_keyword(keyword)

    @articles = policy_scope(articles, policy_scope_class: ArticlesPolicy::Scope)
  end

  def show
    @article = Article.find(params[:id])
  end

  def create
  #   @article = Artist.new(article_params)
  #   @article.save
  #   redirect_to article_path(@article)
  end

  def update
    if @article.update(article_params)
      redirect_to dashboard_path
    end
  end

  def destroy
  end

  def article_params
    params.require(:article).permit(:title, :country)
  end
end


