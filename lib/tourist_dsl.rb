require 'selenium-webdriver'

class TouristDsl
  PUNCHOUT_URL = "http://stage.staplesimprintsolutions.com/StudioJs.aspx?RETURNURL=Punchout.aspx&ACTION=#action#&SKU=#sku#"
	POPUP_WIDTH = 900  # pixels
	TIMEOUT_WAIT = 60  # seconds
	ELEMENTS_SHOW_UP_WAIT = 5 # seconds
	TIMES_TO_RETRY = 5
	DESIGN_TEMPLATES_PER_PAGE = 21
	IFRAME_POPUP_ID = 'iframePopUp'
	DESIGN_TEMPLATE_ID_REGEX = /[[:alnum:]]{8}-[[:alnum:]]{4}-[[:alnum:]]{4}-[[:alnum:]]{4}-[[:alnum:]]{12}/
  SAVE_SHOTS_DIR = "shots"

  module Action
    CREATE = 'create'
  end


  def initialize
		@browser = :firefox

		@driver = Selenium::WebDriver.for @browser
		@wait = Selenium::WebDriver::Wait.new(:timeout => TIMEOUT_WAIT)

    @@sku = nil
    @@action = nil
    @@page = nil
    @@index = nil

    @popup_showing = false  # flag indicating if popup window is showing
  end

  def punchout_batch(sku, action, start_page, end_page)

  end

  def punchout(sku, action = Action::CREATE)
    @@sku = sku
    @@action = action

    url = PUNCHOUT_URL.sub("#sku#", sku).sub("#action#", action)
		navigate_to_page url
  end

  def show_vertical_designs_only
    switch_to_popup_if_necessary

    select_vertical_control
  end

  def go_to_page(page)
    @@page = page

    switch_to_popup_if_necessary

    go_to_page_core page
  end

	def select_design_template_by_index(index)
    @@index = index

		click_targets = @driver.find_elements(:css, '.dtTemplates input')
		target = click_targets[index]
		# onclick = target.attribute 'onclick'
		# template_id = onclick.scan(DESIGN_TEMPLATE_ID_REGEX)[1]
		target.click

		switch_to_main_content
		wait_for_all_elements_to_show
	end

	def take_shot
    save_path = File.join(SAVE_SHOTS_DIR, get_shot_name())
		puts "[Shot] Taking shot at #{save_path}"
		@driver.save_screenshot save_path
		puts "[Shot] Shot taken"
	end

	def end_tour
		switch_to_main_content
		puts '[End] Quiting'
		@driver.quit
		puts '[End] Quitted'
	end

  private

	def navigate_to_page(url)
		puts '[Init] Navigating to page'
		@driver.navigate.to url
		puts '[Init] Navigated to page'
	end

  def switch_to_popup_if_necessary
    unless @popup_showing
      wait_for_design_template_popup
      switch_to_popup_iframe
      @popup_showing = true
    end
  end

  def select_vertical_control
		old_onclick = get_first_design_template_on_page().attribute 'onclick'
		puts '[Refine] Record old onclick value'
    # TODO: better selector?
		vertical_radio_button = @driver.find_element(:css, "div#ContentPlaceHolder1_divVertical input")
    vertical_radio_button.click
		puts '[Refine] Clicked, begin waiting for first template to change'
		@wait.until do
			begin
				get_first_design_template_on_page().attribute('onclick') != old_onclick
			rescue
				false
			end
		end
		puts '[Refine] First element changed'
  end

	def	wait_for_design_template_popup
		puts '[Wait] Waiting for popup'
		iframe_popup = @driver.find_element(:id, 'iframePopUp')
		@wait.until { iframe_popup.size.width == POPUP_WIDTH }
		puts '[Wait] Popup shown'
	end

	def go_to_page_core(number)
		old_onclick = get_first_design_template_on_page().attribute 'onclick'
		puts '[Pager] Record old onclick value'
		page_index_input = @driver.find_element(:css, '#dtPageTitle input')
		page_index_input.send_keys :backspace, :backspace, number.to_s, :return
		puts '[Pager] Send return key, begin waiting for first template to change'
		@wait.until do
			begin
				get_first_design_template_on_page().attribute('onclick') != old_onclick
			rescue
				false
			end
		end
		puts '[Pager] First element changed'
	end

	def get_first_design_template_on_page
		@driver.find_elements(:css, '.dtTemplates input')[0]
	end

	def switch_to_popup_iframe
		puts '[Switch] Switching to popup iframe'
		@driver.switch_to.frame IFRAME_POPUP_ID
		puts '[Switch] Popup iframe shown'
	end

	def switch_to_main_content
		puts '[Switch] Switching to main content'
		@driver.switch_to.default_content
    @popup_showing = false
		puts '[Switch] Main content shown'
	end

	def wait_for_all_elements_to_show
		puts '[Wait] Waiting for all elements to show'
		sleep ELEMENTS_SHOW_UP_WAIT
		puts '[Wait] All elements shown'
	end

  def get_shot_name
    shot_name = "#{@@sku}_#{@@action}"
    shot_name = "#{shot_name}_p#{@@page}_i#{@@index}" unless (@@page.nil? && @@index.nil?)
    shot_name = "#{shot_name}.png"
  end
end

dsl = TouristDsl.new
dsl.punchout("960105")
dsl.show_vertical_designs_only
dsl.go_to_page 3
dsl.select_design_template_by_index 4
dsl.take_shot
dsl.end_tour
