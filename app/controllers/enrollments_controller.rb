class EnrollmentsController < ApplicationController
  before_action :set_enrollment, only: %i[ show edit update destroy ]

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
  end

  # POST /enrollments or /enrollments.json
  def create
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
      if @course.capacity > total_enrollments and @student != nil
        enrollment = Enrollment.new(:student_id => @student.id , :course_id => params[:id])
        enrollment.save
        check_status
      end
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
