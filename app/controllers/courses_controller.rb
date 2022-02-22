class CoursesController < ApplicationController
  before_action :set_course, only: %i[ show edit update destroy enrolled_students waitlisted_students]
  before_action :correct_student?, only: %i[ new edit create update destroy enrolled_students waitlisted_students]
  before_action :correct_instructor?, only: %i[ edit update destroy enrolled_students waitlisted_students]

  # GET /courses or /courses.json
  #Get all the courses, if the user is an instructor, then create a var with this instructor's details pulled from db. 
  def index
    @courses = Course.all
    flash[:controller_from] = 'Course'
    if is_instructor?
      @instructor_id = Instructor.find_by(user_id: current_user.id).id
    end
  end

  #If the user is an instructor, render only courses taught by the instructor
  def instructor_courses
    @courses = Course.all
    if is_instructor?
      @instructor_id = Instructor.find_by(user_id: current_user.id).id
      @courses = Course.where instructor_id: @instructor_id
    end
    render :index
  end

  # GET /courses/1 or /courses/1.json
  #Show course
  def show
  end

  # GET /courses/new
  #Render a form to create new course.
  def new
    @course = Course.new
  end

  # GET /courses/1/edit
  def edit
  end

  # POST /courses or /courses.json
  #Take the course params given from UI. Check if the user is instructor, if yes, then only save these course details to db.
  def create
    @course = Course.new(course_params)
    if is_instructor?
      @instructor = Instructor.find_by user_id: current_user.id
      @course.instructor_id = @instructor.id
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
        fill_enrollments_with_waitlist
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

  #This action checks whether the toal enrollment exceeds total capacity - if yes, then the course is closed. 
  #If the total wait-list capacity is still not met, the status is left as waitlisted instead of closed.
  #Else the status is open. This function is periodically called prior to making any changes
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

  #An action that checks if the user is a student. If yes, block him from performing any course related modifitions. 
  def correct_student?
    @student = Student.find_by user_id: current_user.id
    if !@student.nil?
       flash[:alert] = "Not authorised to perform this action"
       redirect_to courses_path
    end
  end

#An action that checks whether the user is an instructor or not. If so, whether the course that this instructor is accessing is his own course or not. 
  def correct_instructor?
    if is_instructor?
      @instructor = Instructor.find_by user_id: current_user.id
      if @course.instructor.id!=@instructor.id
        flash[:alert] = "Not authorised to perform this action"
        redirect_to courses_path
      end
    end
  end

#Get the enrolled students if the user accessing them is an instructor or admin. 
  def enrolled_students
    if is_instructor? || is_admin?
      @course_name = Course.find(params[:id]).name
      @enrolled_students = Enrollment.where(course_id: params[:id])
    end
  end

#If the user is an isntrucro or admin, then get the waitlisted students corresponding to the course clicked on, in UI. 
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
