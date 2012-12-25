class CourseBaseController < ApplicationController
  before_filter :term_context_needed!
end
