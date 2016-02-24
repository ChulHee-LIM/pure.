class HomeController < ApplicationController

  CafeCreaterTag = 0;
  UserTag = 1;
  CafenameType= 1;
  AddressType = 2;
  UsernameType = 3;
  EmailType = 4;

  def index
    if (user_signed_in?)
      redirect_to '/home/newsfeed'
    end

    @selected_caves = Cafe.all.sample(2)
    @cafe_by_posts = Cafe.all.sort{|a,b| a.posts.count <=> b.posts.count}.reverse!
    # @cafe_by_points = Cafe.order('cafe.avg desc')


    if (user_signed_in? && current_user.id == 1)
      @management = "/cafe/board_management"
      @edit = "/cafe/mainboard_edit"

    else
      @mangement = "#"
      @edit = "#"
    end
  end

  def profile
      @access_to_user = User.where(:user_hash => params[:id]).take
      @visit = @access_to_user.posts.where.not(:cafe_id => 0).select(:cafe_id).map(&:cafe_id).uniq
      @caves = Cafe.all  
      @followers = @access_to_user.followers
      @follows = @access_to_user.follows
      @posts = Post.all
  end
  def like_read
    post = Post.find(params[:id])
    likes = post.likes.all.collect(&:user_id)
    @like_list = Array.new
    for i in 0..likes.size-1
      @like_list.insert(i,User.find(likes[i]))
    end
    render :text => @like_list.to_json 
  end
  def like_save
    like = Like.new
    like.user_id = current_user.id
    like.post_id = params[:post_id].to_i
    like.save
    render :text => ""
  end
  def like_cancel_save
    like = Like.where(user_id: current_user.id, post_id: params[:post_id].to_i)
    like.destroy_all
    render :text => ""
  end

  def create_post
      @caves = Cafe.all
      @post = Post.new
      a=Cafe.where(:name => params[:postcafe]).take
      if a.nil?
        @post.content = params[:postcontent]
        @post.image = params[:postimage]
        @post.address = params[:postcafe]
        @post.hashstr = SecureRandom.hex(11)
        @post.writtentime = DateTime.now
        @post.user_id = current_user.id
        @post.save
          count = params[:count].to_i
        for i in 0..count-1
          unless params[i.to_s] == ""
            Tag.create(:content =>params[i.to_s], 
                       :counting => 0, 
                       :cafe_id => 0, 
                       :post_id => @post.id
                       )
          end
        end
      else
          count = params[:count].to_i
        for i in 0..count-1
          @post.content = params[:postcontent]
          @post.image = params[:postimage]
          @post.address = params[:postcafe]
          @post.hashstr = SecureRandom.hex(11)
          @post.writtentime = DateTime.now
          @post.cafe_id = a.id
          @post.user_id = current_user.id
          unless current_user.id == a.user_id
            @post.score = params[:rating].to_i
          end
          @post.save
            unless params[i.to_s] == ""
            Tag.create(:content =>params[i.to_s], 
                       :counting => 0, 
                       :cafe_id => a.id,
                       :post_id => @post.id
                       )
          end
        end
      end 

      
      if params[:facebook_check] == 'checked'        
        me = FbGraph::User.me(session[:fb_access_token])
        me.photo!(
          :source => params[:postimage], # 'rb' is needed only on windows
          :message => params[:postcontent]
        )        
      end 

      redirect_to(:back)
  end

  def management_cafe
  	if(params[:searchname].nil? || params[:searchname].empty?) 	
		  @caves = Cafe.all
  	else
      if(params[:search_type].to_i == CafenameType)
        @caves = Cafe.where(:name => params[:searchname])
        @caves += Cafe.where("name LIKE ? AND name != ?", "%"+params[:searchname]+"%", params[:searchname])       
      elsif(params[:search_type].to_i == AddressType)
        @caves = Cafe.where("address_road = ? OR address = ?",params[:searchname],params[:searchname])
        @caves += Cafe.where("address_road LIKE ? OR address LIKE ? AND address_road != ? AND address != ?", "%"+params[:searchname]+"%" , "%"+params[:searchname]+"%" , params[:searchname], params[:searchname])
      elsif(params[:search_type].to_i == UsernameType)
        users = User.where(:name => params[:searchname])
        users += User.where("name LIKE ? AND name != ?", "%"+params[:searchname]+"%", params[:searchname])
        @caves = Array.new
        count = 0
        for i in 0..users.size-1
          for j in 0..users[i].caves.size-1
            @caves.insert(count,Cafe.find(j+1))
            count+=1
          end
        end      
      elsif(params[:search_type].to_i == EmailType)
        users = User.where(:email => params[:searchname])
        users += User.where("email LIKE ? AND email != ?", "%"+params[:searchname]+"%", params[:searchname])
        @caves = Array.new
        count = 0
        for i in 0..users.size-1
          for j in 0..users[i].caves.size-1
            @caves.insert(count,Cafe.find(j+1))
            count+=1
          end
        end
      end    
    end
    @search_name = params[:searchname]
    @search_type = params[:search_type].to_i
  end

  def management_edit_cafe
    @cafe = Cafe.find(params[:id])
  end

  def management_save_cafe
    @cafe = Cafe.find(params[:id])
    @cafe.name = params[:cafename]
    @cafe.cafecontact = params[:cafecontact]
    @cafe.signaturemenu = params[:signaturemenu]
    @cafe.introduction = params[:introduction]
    if params[:paid] == 'checked'
      @cafe.paid = true
    else
      @cafe.paid = false
    end
    if params[:visible] == 'checked'
      @cafe.visible = true
    else
      @cafe.visible = false
    end
    @cafe.save
    unless params[:searchtag].empty?
      @tag = Tag.new
      @tag.cafe_id = @cafe.id
      @tag.content = params[:searchtag]
      @tag.tag_type = UserTag
      @tag.save
    end

    redirect_to '/home/management_cafe'
  end

  def management_edit_searchtag
    @tag = Tag.find(params[:id])
  end

  def management_save_searchtag
    @tag = Tag.find(params[:id])
    @tag.content = params[:content]
    @tag.save
    redirect_to '/home/management_edit_cafe/'+ @tag.cafe_id.to_s
  end

  def management_user
    if(params[:searchname].nil? || params[:searchname].empty?)  
      @users = User.all
    else
      if(params[:search_type].to_i == UsernameType)
        @users = User.where(:name => params[:searchname])
        @users += User.where("name LIKE ? AND name != ?", "%"+params[:searchname]+"%", params[:searchname])           
      elsif(params[:search_type].to_i == EmailType)
        @users = User.where(:email => params[:searchname])
        @users += User.where("email LIKE ? AND email != ?", "%"+params[:searchname]+"%", params[:searchname])     
      end     
      @search_name = params[:searchname]      
    end
  end

  def management_edit_user
    @user = User.find(params[:id])
  end

  def management_save_user
    @user = User.find(params[:id])
    @user.name = params[:username]
    @user.email = params[:useremail]
    
    @user.save

    redirect_to '/home/management_user'
  end

  def management_register_cafe
    @user = User.find(params[:id])
  end

  def management_visit_cafe
    @user = User.find(params[:id])
    @caves = Cafe.all
  end

  def management_payinfo
    @cafe = Cafe.all
          
    if((params[:startdate].nil? || params[:startdate].empty?) && (params[:enddate].nil? || params[:enddate].empty?))  
      @payinfos = Payinfo.all
    elsif((params[:startdate].nil? || params[:startdate].empty?) && params[:enddate].present?)
      @payinfos = Payinfo.where("paid_at <= ?",params[:enddate]+" 23:59:59")
    elsif((params[:enddate].nil? || params[:enddate].empty?) && params[:startdate].present?)
      @payinfos = Payinfo.where("paid_at >= ?",params[:startdate]+" 00:00:00") 
    else
      @payinfos = Payinfo.where("paid_at between ? and ?",params[:startdate]+" 00:00:00",params[:enddate]+" 23:59:59")             
    end
    if(params[:searchname].present?)
      if(params[:search_type].to_i == UsernameType)        
        users = User.where("name LIKE ?", "%"+params[:searchname]+"%")
        unless users.empty?
          user_ids = users.collect(&:id)              
          sql = "user_id = #{user_ids[0]}"
          for i in 1..user_ids.size-1
            sql += " OR user_id = #{user_ids[i]}"
          end
          @payinfos = @payinfos.where(sql)
        else
          @payinfos = []     
        end             
      elsif(params[:search_type].to_i == CafenameType)        
        caves = Cafe.where("name LIKE ?", "%"+params[:searchname]+"%")
        unless caves.empty?
          cafe_ids =caves.collect(&:id)               
          sql = "cafe_id = #{cafe_ids[0]}"
          for i in 1..cafe_ids.size-1
            sql += " OR cafe_id = #{cafe_ids[i]}"
          end
          @payinfos = @payinfos.where(sql)
        else
          @payinfos = []     
        end           
      end       
    end
    @search_name = params[:searchname]
    @search_type = params[:search_type].to_i
    @startdate = params[:startdate]
    @enddate = params[:enddate]
  end

  def management_edit_payinfo
    @payinfo = Payinfo.find(params[:id])
  end

  def management_save_payinfo
    redirect_to '/home/management_payinfo'
  end
  
  def help
    @helps = Help.all
  end
  
  def management_save_help
    @helps = Help.new
    @helps.title = params[:title]
    @helps.content = params[:content]
    @helps.save
    
    redirect_to '/home/help'
  end
  
  def management_delete_help
    helps = Help.find(params[:id])
    helps.destroy
    
    
    redirect_to '/home/help'
  end

  def follow_user
    current_user.follow(User.where(:id => params[:id]).take)
    redirect_to(:back)
  end

  def unfollow_user
    current_user.stop_following(User.where(:id => params[:id]).take)
    redirect_to(:back)
  end

  def newsfeed
    @users = User.all
    @followers = current_user.followers
    @follows = current_user.follows
    @cafe = Cafe.all
    @post = []
    @a = []
    @follows.each do |x|
      @a += User.where(:id => x.followable_id)
      @post += User.where(:id => x.followable_id).take.posts.all
    end
    @total = @cafe+@post
    srand cookies[:rand_seed].to_i
    @total_result = @total.shuffle
    @total_result = Kaminari.paginate_array(@total_result).page(params[:page]).per(30)
    if params[:keyword].nil?
     else
    
     jaw =Tag.Where(:content => params[:keyword]).take
     #jaw = params[:keyword]
     render :text =>jaw.to_json
     #render :json =>jaw.to_json
    end
    @tags = Tag.all

  end


  def contact
  end
  
  def contact_process
        titile_mail  = params[:titile_mail]
        address_mail = params[:address_mail]
        content_mail = params[:content_mail]
        SendMail.auotomailer(address_mail, titile_mail, content_mail).deliver_now
        redirect_to '/home/contact'
  end
 
  def cafe_process
        cafename    = params[:cafename]
        cafecontact = params[:cafecontact]
        cafeintro   = params[:intro_detail]
        addrroad    = params[:buyer_addr]
        addrjibun   = params[:address_jibun]
        addrdetail  = params[:address_detail]
        cafe_mail   = params[:cafeemail]
        imgfile     = params[:thumbnail] 
        
        title_mail   = cafename+'가 카페등록 문의 하였습니다.'
        content_mail = '1.카페이름: '+cafename+'
                       '+'2.카페주소: '+addrroad+'(도로명)   '+addrjibun+'(지번주소)   '+addrdetail+'(상세주소)'+'
                       '+'3.연락처: '+cafecontact+'
                       '+'4.요청사항: '+cafeintro

        SendCafe.cafemailer(cafe_mail, title_mail, content_mail, imgfile).deliver_now
        redirect_to(:back)  
  end
  
  
  def agreement
  end
  
  def privacy
  end
  
  def logos
    logo = Logo.new
    logo.index = params[:index_logo]
    logo.other = params[:others_logo]
    logo.save
    redirect_to (:back)
  end

 def addtag
  
   ids_array = Array.new
   ids_array = params[:selected_ids]
   selected_tag =Tag.where(:id => ids_array).uniq
   user =User.where(:id => current_user.id).take  
    selected_tag.each do |t|
      user.tags << t
    end 
    
  end


  def mtest
    if params[:keyword].nil?
    else
    
    jaw =Tag.Where(:id => params[:keyword].to_i).take
    #jaw = params[:keyword]
    render :text =>jaw.to_json
    #render :json =>jaw
    end
    @tags = Tag.all
  end
 
  def usersearch
    user = User.where(:name => params[:user_search]).take
    if user.nil?
      flash[:alert] = 'sorry, we can\'t'
      redirect_to(:back)
    else
      redirect_to action:'profile' , id: user.user_hash
    end
  end

  def searching
      if params[:keyword]=="" 
      else
      jaw =Tag.new
      #jaw = Tag.where(:content => params[:keyword]).take
      jaw=Tag.where("content LIKE ?", "%"+params[:keyword]+"%")
      render :text =>jaw.to_json
      
      end
  end    
  
 end
