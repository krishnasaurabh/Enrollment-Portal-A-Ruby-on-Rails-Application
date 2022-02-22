class WaitlistsController < ApplicationController
  before_action :set_waitlist, only: %i[ show edit update destroy ]
  before_action :correct_student?, only: %i[ edit update destroy show ]
  before_action :correct_instructor?, only: %i[ edit update destroy show create ]

  # GET /waitlists or /waitlists.json
  def index
    if is_student?
      # this shows waitlists for the current user
      @waitlists = Waitlist.where(student_id: Student.find_by(user_id: current_user.id).id)
    elsif is_instructor?
      # blocks access to instructor as he can see from the courses details page
      flash[:alert] = "Not authorised to perform this action"
      redirect_to courses_path
    elsif is_admin?
      #  this shows all the waitlists for all students
      @waitlists = Waitlist.all
    end
  end

  # GET /waitlists/1 or /waitlists/1.json
  def show
  end

  # GET /waitlists/new
  def new
    @waitlist = Waitlist.new
  end

  # GET /waitlists/1/edit
  def edit
    flash[:alert] = "Not authorised to perform this action"
    redirect_to courses_path
  end

  # POST /waitlists or /waitlists.json
  def create
    waitlist_course
    respond_to do |format|
      if @waitlist.save
        @course = Course.find(@waitlist.course_id)
        check_status
        format.html { redirect_to waitlisted_students_path(@course.id), notice: "Waitlist was successfully created." }
        format.json { render :show, status: :created, location: @waitlist }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json:{}, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /waitlists/1 or /waitlists/1.json
  def update
    respond_to do |format|
      if @waitlist.update(waitlist_params)
        @course = Course.find(@waitlist.course_id)
        check_status
        format.html { redirect_to waitlist_url(@waitlist), notice: "Waitlist was successfully updated." }
        format.json { render :show, status: :ok, location: @waitlist }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json:  @waitlist.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /waitlists/1 or /waitlists/1.json
  def destroy
    @course = Course.find(@waitlist.course_id)
    @waitlist.destroy
    check_status
    respond_to do |format|

      if is_instructor?
        format.html { redirect_to waitlisted_students_url(@waitlist.course_id), alert: "Waitlist for #{@course.name} is dropped." }
      elsif flash[:controller_from] == "Course"
        format.html { redirect_to courses_path, alert: "Waitlist for #{@course.name} is dropped." }
      else
        format.html { redirect_to waitlists_url, alert: "Waitlist for #{@course.name} is dropped." }
      end

      format.json { head :no_content }
    end
  end

  # this will check the status for a course and modify it based on the number of enrollments and waitlists
  # it considers the course waitlist_capacity and the capacity to dermine the status of the course
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


  #  GET /waitlist_course/:id or /waitlist_course/1
  # this is for a student to waitlist a course
  def waitlist_course
    @waitlist = Waitlist.new

    if !is_student? && (!waitlist_params[:course_id] || !waitlist_params[:student_id])
      flash[:alert] = "course and student should not be empty"
      return
    end
    if is_student?
      @course = Course.find(params[:id])
      @student = Student.find_by user_id: current_user.id
    else
      @course = Course.find(waitlist_params[:course_id])
      @student = Student.find waitlist_params[:student_id]
    end

    total_waitlist = Waitlist.where(course_id: @course.id).count
    total_enrollment = Enrollment.where(course_id: @course.id).count
    if @course.capacity > total_enrollment
      flash[:alert] = "Enrollment is still open for the course please go to enrollments to enroll for the course"
    elsif Enrollment.find_by(student_id: @student.id, course_id: @course.id)
      flash[:alert] = "Student is already enrolled for this course"
    elsif Waitlist.find_by(student_id: @student.id, course_id: @course.id)
      flash[:alert] = "Student is already waitlisted for this course"
    elsif @course.status == "waitlist" && @course.waitlist_capacity > total_waitlist and @student != nil
      @waitlist.student_id = @student.id
      @waitlist.course_id = @course.id
      if is_student?
        flash[:alert] = "Successfully waitlisted for the course #{@course.name}"
        @waitlist.save
      end
      check_status
    elsif @course.waitlist_capacity <= total_waitlist
      flash[:alert] = "Course status is closed, please keep checking MyBiryaniPack protal when it opens up."
    end
    if is_student?
      redirect_to courses_path
    end
  end

  # /courses/:id/waitlisted_students 
  # shows all students waitlist in the course passed as arguemnt
  # this is visible by admin and authorized instructor
  def show_waitlist_course_for_student
    @waitlist = Waitlist.new
    @course = Course.find params[:course_id]
    render :new
  end

  # this will block operations that student should not access
  def correct_student?
    @student = Student.find_by user_id: current_user.id
    if !@student.nil? && @student.id!=@waitlist.student_id
       flash[:alert] = "Not authorised to perform this action"
       redirect_to root_path
    end
  end

  # this will block operations that instructor should not access
  # it will block the instructor if the course whose enrollments are not belongging to his/her course
  def correct_instructor?
    if is_instructor?
      @instructor = Instructor.find_by user_id: current_user.id
      course_instructor_id = 0
      if @waitlist
        course_instructor_id = @waitlist.course.instructor.id
      else
        course_instructor_id = Course.find(waitlist_params[:course_id]).instructor.id
      end
      if !@instructor.nil? && @instructor.id!=course_instructor_id
        flash[:alert] = "Not authorised to perform this action"
        redirect_to root_path
      end
    end
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_waitlist
      @waitlist = Waitlist.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def waitlist_params
      params.require(:waitlist).permit(:student_id, :course_id)
    end
end
