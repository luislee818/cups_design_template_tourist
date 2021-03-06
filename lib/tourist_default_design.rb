require 'selenium-webdriver'
require 'fileutils'

class Tourist
	POPUP_WIDTH = 900  # pixels
	TIMEOUT_WAIT = 60  # seconds
	ELEMENTS_SHOW_UP_WAIT = 5 # seconds
	TIMES_TO_RETRY = 5
	DESIGN_TEMPLATES_PER_PAGE = 21
	IFRAME_POPUP_ID = 'iframePopUp'
	DESIGN_TEMPLATE_ID_REGEX = /[[:alnum:]]{8}-[[:alnum:]]{4}-[[:alnum:]]{4}-[[:alnum:]]{4}-[[:alnum:]]{12}/
  SAVE_SHOTS_DIR = "shots"

	def initialize
		@skus = ['..FBC256', '17428HQFC']
		@browser = :firefox

		@driver = Selenium::WebDriver.for @browser
		@wait = Selenium::WebDriver::Wait.new(:timeout => TIMEOUT_WAIT)
		@first_spot = true
	end

	def begin_tour
		@skus.each do |sku|
			tour_sku sku
			end_sku_tour
		end

		end_tour
	end

	def end_sku_tour
	end

	def tour_sku(sku)
		dir = File.join(SAVE_SHOTS_DIR, sku.to_s)
		url = "http://stage.staplesimprintsolutions.com/StudioJs.aspx?RETURNURL=Punchout.aspx&ACTION=CREATE&SKU=#{sku}"
		FileUtils.mkdir_p(dir) unless File.directory?(dir)
		puts "----- SKU #{sku} -----"

    retry_upon_failure(TIMES_TO_RETRY) do
      puts "----- page #{@current_page}, index #{@current_index}, start #{Time.now} -----"

      template_id = go_to_spot(url, @current_page, @current_index, sku)

      take_shot(@current_page, @current_index, sku, template_id)
    end
	end

	def retry_upon_failure(number_to_retry, &block)
		number_to_retry.times do |index|
			begin
				puts "----- retrying ##{index + 1} -----" if index > 0
				block.call
				break
			rescue
				puts "----- error when trying for ##{index + 1} -----"
			end
		end
	end

	def go_to_spot(url, page, index, sku)
		navigate_to_page url

		if @first_spot
			@first_spot = false
		else
			puts '[Confirm] Confirming leaving page'
			@driver.switch_to.alert.accept unless @first_spot
			puts '[Confirm] Confirmed leaving page'
		end

		# wait_for_design_template_popup
		# switch_to_popup_iframe

		# save_max_page_number if @max_page == -1
		# go_to_page page unless page == 1
		# save_maximum_index_of_page

		# template_id = select_design_template index
    template_id = 'na'
		# switch_to_main_content
		wait_for_all_elements_to_show

		popup_warning = @driver.find_element(:id, 'divPopUp')
		if popup_warning.attribute('style').index('display: block')
			puts '[Warning] Popup warning shown'
			puts '[Warning] Saving screenshot for warning'
			@driver.save_screenshot File.join(SAVE_SHOTS_DIR, sku.to_s, "#{sku}.png")
			puts '[Warning] Saved screenshot for warning'
			@driver.find_element(:css, '#divPopUp #doOk').click
			puts '[Warning] Popup warning dismissed'
		end

		template_id
	end

	def navigate_to_page(url)
		puts '[Init] Navigating to page'
		@driver.navigate.to url
		puts '[Init] Navigated to page'
	end

	def click_change_design_link
		puts '[Change Design] Clicking change design link'
		change_design_link = @driver.find_element(:link_text, 'Change Design')
		change_design_link.click
		puts '[Change Design] Clicked change design link'
	end

	def	wait_for_design_template_popup
		puts '[Wait] Waiting for popup'
		iframe_popup = @driver.find_element(:id, 'iframePopUp')
		@wait.until { iframe_popup.size.width == POPUP_WIDTH }
		puts '[Wait] Popup shown'
	end

	def switch_to_popup_iframe
		puts '[Switch] Switching to popup iframe'
		@driver.switch_to.frame IFRAME_POPUP_ID
		puts '[Switch] Popup iframe shown'
	end

	def save_max_page_number
		puts '[Pager] Looking for maximum page number'
		page_number_input = @driver.find_element(:css, '#dtPageOf #pageOfValue input')
		@max_page = page_number_input.attribute('value').to_i
		@page_end = @max_page
		puts "[Pager] Maximum page number saved as #{@max_page}"
	end

	def go_to_page(number)
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

	def save_maximum_index_of_page
		puts '[Pager] Looking for maximum index of current page'
		@index_end = @driver.find_elements(:css, '.dtTemplates').length - 1
		puts "[Pager] Maximum index of current page saved as #{@index_end}"
	end

	def select_design_template(index)
		click_targets = @driver.find_elements(:css, '.dtTemplates input')
		target = click_targets[index]
		onclick = target.attribute 'onclick'
		template_id = onclick.scan(DESIGN_TEMPLATE_ID_REGEX)[1]
		target.click

		template_id
	end

	def get_first_design_template_on_page
		@driver.find_elements(:css, '.dtTemplates input')[0]
	end

	def switch_to_main_content
		puts '[Switch] Switching to main content'
		@driver.switch_to.default_content
		puts '[Switch] Main content shown'
	end

	def wait_for_all_elements_to_show
		puts '[Wait] Waiting for all elements to show'
		sleep ELEMENTS_SHOW_UP_WAIT
		puts '[Wait] All elements shown'
	end

	def take_shot(page, index, sku, template_id)
		shot_name = "#{sku}.png"
		puts "[shot] taking shot for #{shot_name}"
		file = File.join(SAVE_SHOTS_DIR, sku.to_s, shot_name)
		@driver.save_screenshot file
		puts "[Shot] Shot taken"
	end

	def end_tour
		switch_to_main_content
		puts '[End] Quiting'
		@driver.quit
		puts '[End] Quitted'
	end

end

p = Tourist.new
p.begin_tour
