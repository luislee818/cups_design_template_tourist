class Tourist
	def	draw_map(sku, start = nil, stop = nil)
		@start = start
		@stop = stop
	end

	def get_map
		{
			group: get_groups,
			start: @start || Marker.new(1, 0),
			stop: @stop
		}
	end

	def get_groups
		[]
	end
end

Marker = Struct.new(:page_start, :index_start)

describe "Tourist" do
	describe "draw_map" do
		context "only sku is passed in" do
			DEFAULT_START_MARKER = Marker.new(1, 0)  # page 1, index 0

			before do
				@sku = 123456
				@tourist = Tourist.new
			end

			context "sku does not have popup menu" do
				before do
					@tourist.draw_map @sku
					@map = @tourist.get_map
				end

				it "should return hash with :group be empty array" do
					@map[:group].should == []
				end
			end

			context "sku has popup menu" do
				before do
					@tourist.stub(:has_popup_menu).and_return(true)
				end

				context "sku does not have groups" do
					before do
						@tourist.stub(:get_groups).and_return([])

						@tourist.draw_map @sku
						@map = @tourist.get_map
					end

					it "should return hash with :group be empty array" do
						@map[:group].should == []
					end
				end

				context "sku has groups" do
					before do
						@groups = %q(horizontal, vertical)

						@tourist.stub(:get_groups).and_return(@groups)
						@tourist.draw_map @sku
						@map = @tourist.get_map
					end

					it "should return hash with :group be the one returned from get_groups" do
						@map[:group].should == @groups
					end
				end

				context "start is not specified" do
					before do
						@tourist.draw_map @sku
						@map = @tourist.get_map
					end

					it "should return default start marker as begin" do
						@map[:start].should == DEFAULT_START_MARKER
					end
				end

				context "start is specified" do
					before do
						@start = Marker.new(10, 15)  # page 10, index 15
						@tourist.draw_map @sku, @start
						@map = @tourist.get_map
					end

					it "should return default start marker as start" do
						@map[:start].should == @start
					end
				end

				context "stop is not specified" do
					before do
						@tourist.draw_map @sku
						@map = @tourist.get_map
					end

					it "should return nil as stop" do
						@map[:stop].should == nil
					end
				end

				context "stop is specified" do
					before do
						@stop = Marker.new(12, 18)  # page 12, index 18
						@tourist.draw_map @sku, nil, @stop
						@map = @tourist.get_map
					end

					it "should return default start marker as stop" do
						@map[:stop].should == @stop
					end
				end
			end
		end
	end
end
