class CoursesController < ApplicationController
  before_action :set_course, only: %i[ show edit update destroy enrolled_students waitlisted_students]
  before_action :correct_student?, only: %i[ new edit create update destroy enrolled_students waitlisted_students]
  before_action :correct_instructor?, only: %i[ edit update destroy enrolled_students waitlisted_students]

  # GET /courses or /courses.json
  def index
      @courses = Course.all
  end

  # GET /courses/1 or /courses/1.json
  def show
  end

  # GET /courses/new
  def new
    @course = Course.new
  end

  # GET /courses/1/edit
  def edit
  end

  # POST /courses or /courses.json
  def create
    @course = Course.new(course_params)
    if is_instructor?
      @course.instructor_id = current_user.id
    end
    respond_to do |format|
      if @course.save
        check_status
        format.html { redirect_to course_url(@course), notice: "Course was successfully created." }
        format.json { render :show, status: :created, location: @course }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @course.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /courses/1 or /courses/1.json
  def update
    respond_to do |format|
      if @course.update(course_params)
        check_status
        format.html { redirect_to course_url(@course), notice: "Course was successfully updated." }
        format.json { render :show, status: :ok, location: @course }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @course.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /courses/1 or /courses/1.json
  def destroy
    @course.destroy

    respond_to do |format|
      format.html { redirect_to courses_url, notice: "Course was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def check_status
    total_enrollments = Enrollment.where(course_id: @course.id).count
    total_waitlist = Waitlist.where(course_id: @course.id).count
    
    if total_enrollments >= @course.capacity
      if total_waitlist >= @course.waitlist_capacity
        @course.status = :closed
      else
        @course.status = :waitlist
      end
    elsif total_enrollments < @course.capacity && (@course.status == "closed" || @course.status == "waitlist")
      @course.status = :open
    end
    @course.save
  end

  def correct_student?
    @student = Student.find_by user_id: current_user.id
    if !@student.nil?
       flash[:alert] = "Not authorised to perform this action"
       redirect_to courses_path
    end
  end

  def correct_instructor?
    if is_instructor?
      @instructor = Instructor.find_by user_id: current_user.id
      if @course.instructor_id!=@instructor.id
        flash[:alert] = "Not authorised to perform this action"
        redirect_to courses_path
      end
    end
  end

  def enrolled_students
    if is_instructor? || is_admin?
      @course_name = Course.find(params[:id]).name
      @enrolled_students = Enrollment.where(course_id: params[:id])
    end
  end

  def waitlisted_students
    if is_instructor? || is_admin?
      @course_name = Course.find(params[:id]).name
      @waitlisted_students = Waitlist.where(course_id: params[:id])
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_course
      @course = Course.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def course_params
      params.require(:course).permit(:name, :description, :weekday_one, :weekday_two, :start_time, :end_time, :course_code, :capacity, :waitlist_capacity, :status, :room, :instructor_id)
    end
end
