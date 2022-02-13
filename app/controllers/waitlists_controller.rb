class WaitlistsController < ApplicationController
  before_action :set_waitlist, only: %i[ show edit update destroy ]

  # GET /waitlists or /waitlists.json
  def index
    if is_student?
      @waitlists = Waitlist.where(student_id: Student.find_by(user_id: current_user.id).id)
    elsif is_instructor?
      flash[:alert] = "Not authorised to perform this action"
      redirect_to courses_path
    elsif is_admin?
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
    render :file => "#{Rails.root}/public/404.html",  layout: false, status: :not_found
    # flash[:alert] = "Not authorised to perform this action"
    # redirect_to courses_path
  end

  # POST /waitlists or /waitlists.json
  def create
    @waitlist = Waitlist.new(waitlist_params)
    respond_to do |format|
      if @waitlist.save
        @course = Course.find(@waitlist.course_id)
        check_status
        format.html { redirect_to waitlist_url(@waitlist), notice: "Waitlist was successfully created." }
        format.json { render :show, status: :created, location: @waitlist }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @waitlist.errors, status: :unprocessable_entity }
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
        format.json { render json: @waitlist.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /waitlists/1 or /waitlists/1.json
  def destroy
    @course = Course.find(@waitlist.course_id)
    @waitlist.destroy
    check_status
    respond_to do |format|
      format.html { redirect_to waitlists_url, notice: "Waitlist was successfully destroyed." }
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

  def waitlist_course
    if is_student?
      @course = Course.find(params[:id])
      @student = Student.find_by user_id: current_user.id
      total_waitlist = Waitlist.where(course_id: @course.id).count
      if Enrollment.find_by(student_id: @student.id, course_id: @course.id)
        flash[:alert] = "You have already enrolled for this course"
      elif Waitlist.find_by(student_id: @student.id, course_id: @course.id)
        flash[:alert] = "You have already waitlisted for this course"
      elsif @course.status == "waitlist" && @course.waitlist_capacity > total_waitlist and @student != nil
        waitlist = Waitlist.new(:student_id => @student.id , :course_id => params[:id])
        waitlist.save
        check_status
      elsif @course.waitlist_capacity <= total_waitlist
        flash[:alert] = "Course status is closed, please keep checking MyBiryaniPack protal when it opens up."
      end
    end
    redirect_to courses_path
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
