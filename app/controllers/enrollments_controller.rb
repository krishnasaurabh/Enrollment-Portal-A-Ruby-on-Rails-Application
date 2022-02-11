class EnrollmentsController < ApplicationController
  before_action :set_enrollment, only: %i[ show edit update destroy ]
  before_action :correct_student?, only: %i[ edit update destroy show]


  # GET /enrollments or /enrollments.json
  def index
    if is_student?
      @enrollments = Enrollment.where(student_id: Student.find_by(user_id: current_user.id).id)
    else
      @enrollments = Enrollment.all
    end
  end

  # GET /enrollments/1 or /enrollments/1.json
  def show
  end

  # GET /enrollments/new
  def new
    @enrollment = Enrollment.new
  end

  # GET /enrollments/1/edit
  def edit
    flash[:alert] = "Not authorised to perform this action"
    redirect_to courses_path
  end

  # POST /enrollments or /enrollments.json
  def create
    if is_instructor?
      enroll_course_for_student
    else
      @enrollment = Enrollment.new(enrollment_params)
      respond_to do |format|
        if @enrollment.save
          @course = Course.find(@enrollment.course_id)
          check_status
          format.html { redirect_to enrollment_url(@enrollment), notice: "Enrollment was successfully created." }
          format.json { render :show, status: :created, location: @enrollment }
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @enrollment.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # PATCH/PUT /enrollments/1 or /enrollments/1.json
  def update
    respond_to do |format|
      if @enrollment.update(enrollment_params)
        @course = Course.find(@enrollment.course_id)
        check_status
        format.html { redirect_to enrollment_url(@enrollment), notice: "Enrollment was successfully updated." }
        format.json { render :show, status: :ok, location: @enrollment }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @enrollment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /enrollments/1 or /enrollments/1.json
  def destroy
    @course = Course.find(@enrollment.course_id)
    @enrollment.destroy
    check_status
    respond_to do |format|
      format.html { redirect_to enrollments_url, notice: "Enrollment was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def enroll_course

    if is_student?
      @course = Course.find(params[:id])
      @student = Student.find_by user_id: current_user.id
      total_enrollments = Enrollment.where(course_id: @course.id).count
      if Enrollment.find_by(student_id: @student.id, course_id: @course.id)
        flash[:alert] = "You have already registered for this course"
      elsif @course.capacity > total_enrollments and @student != nil
        enrollment = Enrollment.new(:student_id => @student.id , :course_id => params[:id])
        enrollment.save
        check_status
      elsif @course.capacity <= total_enrollments
        flash[:alert] = "Course status is closed, please keep checking MyBiryaniPack protal when it opens up."
      end
    end
    redirect_to courses_path
  end

  def show_enroll_course_for_student
    @enrollment = Enrollment.new
    @course_id_enroll = params[:course_id]
    render :new
  end


  def enroll_course_for_student
    @course = Course.find(enrollment_params[:course_id])
    @instructor = Instructor.find_by user_id: current_user.id
    if @course.instructor_id != @instructor.id #IF the current course is not by this instructor
      flash[:alert] = "Not authorised to perform this action"
    elsif Enrollment.find_by(enrollment_params)
      flash[:alert] = "The student is already registered for this course"
    elsif @course.status == 'open'
      enrollment = Enrollment.new(enrollment_params)
      enrollment.save
      check_status
    elsif @course.status == 'closed'
      flash[:alert] = "Course status is closed, please keep checking MyBiryaniPack protal when it opens up."
    end
    redirect_to courses_path
  end

  def check_status
    total_enrollments = Enrollment.where(course_id: @course.id).count
    if total_enrollments >= @course.capacity && @course.status == "open"
      @course.status = :closed
      @course.save
    elsif total_enrollments < @course.capacity && @course.status == "closed"
      @course.status = :open
      @course.save
    end
  end

  def correct_student?
    @student = Student.find_by user_id: current_user.id
    if !@student.nil? && @student.id!=@enrollment.student_id
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_enrollment
      @enrollment = Enrollment.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def enrollment_params
      params.require(:enrollment).permit(:student_id, :course_id)
    end
end
