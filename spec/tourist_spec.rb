class Tourist
	def	draw_map(sku, start = nil, stop = nil)
		@start = start
		@stop = stop
	end

	def draw_map(sku, groups = nil)
		@sku = sku
		@groups = groups
	end

	def get_map
		map = TourMap.new
		map.sku = @sku
		map.groups = @groups || get_groups
		map
	end

	def get_groups
		[]
	end
end

class TourMap
	attr_accessor :sku, :groups, :start_from, :stop_at
end

Marker = Struct.new(:page_start, :index_start)

describe "Tourist" do
	describe "draw_map" do
		before do
			@tourist = Tourist.new
			@sku = 123456
		end

		it "sku on tour map should be sku passed in" do
			@tourist.draw_map @sku
			@map = @tourist.get_map

			@map.sku.should == @sku
		end

		context "sku does not have menu to choose groups or pages" do
			before do
				@tourist.stub(:single_spot?).and_return(true)
				@tourist.draw_map @sku
				@map = @tourist.get_map
			end

			it "groups on tour map should be empty array" do
				@map.groups.should == []
			end

			it "start_from on tour map should be nil" do
				@map.start_from.should be_nil
			end

			it "stop_at on tour map should be nil" do
				@map.stop_at.should be_nil
			end

		end

		context "sku has menu to choose groups or pages" do
			context "sku supports groups" do
				before do
					@groups = %q(horizontal, vertical)
					@tourist.stub(:get_groups).and_return(@groups)
				end

				context "groups is not passed in" do
					it "groups on tour map should be the value returned from get_groups" do
						@tourist.draw_map @sku
						@map = @tourist.get_map

						@map.groups.should == @groups
					end
				end

				context "groups is passed in" do
					it "groups on tour map should be the value passed in" do
						specified_groups = %q(horizontal)
						@tourist.draw_map @sku, specified_groups
						@map = @tourist.get_map

						@map.groups.should == specified_groups
					end
				end
			end

			context "sku does not support groups" do
				before do
					@groups = []
					@tourist.stub(:get_groups).and_return(@groups)
				end

				it "groups on tour map should be empty array" do
					@tourist.draw_map @sku
					@map = @tourist.get_map

					@map.groups.should == []
				end
			end

			context "sku supports pages" do
				context "start_from is not passed in"

				context "start_from is passed in"

				context "stop_at is not passed in"

				context "stop_at is passed in"

			end

			context "sku does not support pages"
		end

		# context "only sku is passed in" do
		# 	DEFAULT_START_MARKER = Marker.new(1, 0)  # page 1, index 0

		# 	before do
		# 	end

		# 	context "sku does not have popup menu" do
		# 		before do
		# 			@tourist.draw_map @sku
		# 			@map = @tourist.get_map
		# 		end

		# 		it "should return hash with :group be empty array" do
		# 			@map[:group].should == []
		# 		end
		# 	end

		# 	context "sku has popup menu" do
		# 		before do
		# 			@tourist.stub(:has_popup_menu).and_return(true)
		# 		end

		# 		context "sku does not have groups" do
		# 			before do
		# 				@tourist.stub(:get_groups).and_return([])

		# 				@tourist.draw_map @sku
		# 				@map = @tourist.get_map
		# 			end

		# 			it "should return hash with :group be empty array" do
		# 				@map[:group].should == []
		# 			end
		# 		end

		# 		context "sku has groups" do
		# 			before do
		# 				@groups = %q(horizontal, vertical)

		# 				@tourist.stub(:get_groups).and_return(@groups)
		# 				@tourist.draw_map @sku
		# 				@map = @tourist.get_map
		# 			end

		# 			it "should return hash with :group be the one returned from get_groups" do
		# 				@map[:group].should == @groups
		# 			end
		# 		end

		# 		context "start is not specified" do
		# 			before do
		# 				@tourist.draw_map @sku
		# 				@map = @tourist.get_map
		# 			end

		# 			it "should return default start marker as begin" do
		# 				@map[:start].should == DEFAULT_START_MARKER
		# 			end
		# 		end

		# 		context "start is specified" do
		# 			before do
		# 				@start = Marker.new(10, 15)  # page 10, index 15
		# 				@tourist.draw_map @sku, @start
		# 				@map = @tourist.get_map
		# 			end

		# 			it "should return default start marker as start" do
		# 				@map[:start].should == @start
		# 			end
		# 		end

		# 		context "stop is not specified" do
		# 			before do
		# 				@tourist.draw_map @sku
		# 				@map = @tourist.get_map
		# 			end

		# 			it "should return nil as stop" do
		# 				@map[:stop].should == nil
		# 			end
		# 		end

		# 		context "stop is specified" do
		# 			before do
		# 				@stop = Marker.new(12, 18)  # page 12, index 18
		# 				@tourist.draw_map @sku, nil, @stop
		# 				@map = @tourist.get_map
		# 			end

		# 			it "should return default start marker as stop" do
		# 				@map[:stop].should == @stop
		# 			end
		# 		end
		# 	end
		# end
	end
end
