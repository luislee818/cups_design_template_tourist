require 'selenium-webdriver'

class Tourist
	POPUP_WIDTH = 900  # pixels
	WAIT = 30  # seconds
	IFRAME_POPUP_ID = 'iframePopUp'
	DESIGN_TEMPLATE_ID_REGEX = /[[:alnum:]]{8}-[[:alnum:]]{4}-[[:alnum:]]{4}-[[:alnum:]]{4}-[[:alnum:]]{12}/

	def initialize
		@sku = 960105
		@browser = :firefox
		@url = "http://stage.staplesimprintsolutions.com/StudioJs.aspx?RETURNURL=Punchout.aspx&ACTION=CREATE&SKU=#{@sku}"
		@dir = @sku.to_s

		@driver = Selenium::WebDriver.for @browser
		@wait = Selenium::WebDriver::Wait.new(:timeout => WAIT)
		@index_start = 8
		@index_end = 12
		@current_index = @index_start
		@first_spot = true
	end

	def begin_tour
		Dir.mkdir(@dir) unless File.directory?(@dir)

		while @current_index <= @index_end
			go_to_next_spot

			@current_index += 1
		end

		end_tour
	end

	def	wait_for_design_template_popup()
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

	def switch_to_main_content
		puts '[Switch] Switching to main content'
		@driver.switch_to.default_content
		puts '[Switch] Main content shown'
	end

	def wait_for_all_elements_to_show
		puts '[Wait] Waiting for all elements to show'
		sleep 10
		puts '[Wait] All elements shown'
	end

	def click_change_design_link
		puts '[Change Design] Clicking change design link'
		change_design_link = @driver.find_element(:link_text, 'Change Design')
		change_design_link.click
		puts '[Change Design] Clicked change design link'
	end

	def take_shot(index, template_id)
		shot_name = "#{index}. #{template_id}.png"
		puts "[Shot] Taking shot for #{shot_name}"
		@driver.save_screenshot "./#{@dir}/#{shot_name}"
		puts "[Shot] Shot taken"
	end

	def navigate_to_page
		puts '[Init] Navigating to page'
		@driver.navigate.to @url
		puts '[Init] Navigated to page'
	end

	def select_design_template(index)
		click_targets = @driver.find_elements(:css, '.dtTemplates input')
		target = click_targets[index]
		onclick = target.attribute 'onclick'
		template_id = onclick.scan(DESIGN_TEMPLATE_ID_REGEX)[1]
		target.click

		template_id
	end

	def go_to_next_spot
		if @first_spot
			navigate_to_page
			@first_spot = false
		else
			click_change_design_link
		end

		wait_for_design_template_popup()
		switch_to_popup_iframe
		template_id = select_design_template @current_index
		switch_to_main_content
		wait_for_all_elements_to_show

		take_shot(@current_index, template_id)
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
