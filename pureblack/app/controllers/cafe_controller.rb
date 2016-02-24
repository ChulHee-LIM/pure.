class CafeController < ApplicationController
	
  CafeCreaterTag = 0;
  UserTag = 1;

  def cafesearch
    cafe_reorder = 0
    if params[:cafe_reorder].present?
      cafe_reorder = params[:cafe_reorder].to_i
    end
    
    @search = params[:searchword]
    tags = Tag.where(:content => params[:searchword]).where.not(:cafe_id=>0)
    tags.each do |tag|
      tag.increment!(:counting)
    end
    prev = params[:searchword]
    tags += Tag.where("content LIKE ? AND content != ?", "%"+params[:searchword]+"%", params[:searchword]).where.not(:cafe_id=>0)
    ids = tags.collect(&:cafe_id).uniq.sort
    coffee = Array.new
    cafetags = Array.new
   
    for i in 0..ids.size-1
      coffee.insert(i,Cafe.where(:id => ids[i]).take)
      cafetags+= Tag.where(:cafe_id =>ids[i]).where.not(:content=> params[:searchword]).where.not(:cafe_id=>0).where.not(:content=>"")
    end

    if cafe_reorder == 1
      @cafe = coffee.sort {|a, b| a.posts.count <=> b.posts.count }.reverse!
    else
      @cafe = coffee.sort {|a, b| a.avg <=> b.avg }.reverse!
    end
    if cafe_reorder == 2
      if params[:meal_available] == "true"
        @cafe.delete_if{|x| x.meal_available != true}
      end
      if params[:parking] == "true"
        @cafe.delete_if{|x| x.parking != true}
      end
      if params[:wifi] == "true"
        @cafe.delete_if{|x| x.wifi != true}
      end
      if params[:sidemenu] == "true"
        @cafe.delete_if{|x| x.sidemenu != true}
      end
      if params[:animal_available] == "true"
        @cafe.delete_if{|x| x.animal_available != true}
      end
      if params[:in_house_roasting] == "true"
        @cafe.delete_if{|x| x.in_house_roasting != true}
      end
      if params[:smoke] == "true"
        @cafe.delete_if{|x| x.smoke != true}
      end
      if params[:today_business_check] == "true"
        @cafe.delete_if{|x| x.today_business_check != true}
      end
    end
    @aa=cafetags.sort_by {|m| m[:counting]}.reverse!
    @hashtags = @aa.collect(&:content).uniq
    @navsearch = params[:searchword] #application_html 의 #navbar에서 사용
  end  

  def cafedetail
    @cafe = Cafe.where(:cafehash => params[:hash]).take
    @cafe_tags=Tag.where(:cafe_id => @cafe.id)
  end

  def cafe_edit
    edit = Cafe.where(:id => params[:id]).take
    edit.thumnail = params[:thumbnail]
    edit.image = params[:cafeimage]
    edit.signaturemenu = params[:signaturemenu] 
    edit.cafecontact = params[:cafecontact] 
    edit.introduction = params[:intro_detail]
    edit.webinfo_address = params[:webinfo_adderess]
    edit.facebook_address = params[:facebook_address]
    edit.instagram_adderess = params[:instagram_adderess]
    edit.blog_address = params[:blog_adderess]
    edit.machine = params[:machine]
    edit.grinder = params[:grinder]
    edit.bean = params[:beans]
    edit.brewing_method = params[:brewing_method]
    edit.business_hour = params[:opening_time]+"~"+params[:closing_time]
    if params[:meal_available] == 'checked'
      edit.meal_available = true
    else
      edit.meal_available = false
    end
    if params[:parking] == 'checked'
      edit.parking = true
    else
      edit.parking = false
    end
    if params[:wifi] == 'checked'
      edit.wifi = true
    else
      edit.wifi = false
    end
    if params[:sidemenu] == 'checked'
      edit.sidemenu = true
    else
      edit.sidemenu = false
    end
    if params[:animal_available] === 'checked'
      edit.animal_available = true
    else
      edit.animal_available = false
    end
    if params[:in_house_roasting] == 'checked'
      edit.in_house_roasting  = true
    else
      edit.in_house_roasting = false
    end
    if params[:today_business_check] == 'checked'
      edit.today_business_check = true
    else
      edit.today_business_check = false
    end
    if params[:smoke] == 'checked'
      edit.smoke = true
    else
      edit.smoke = false
    end

    # for i in 0..count-1

    # end
    edit.save
    tag1 = Tag.where(:id =>params[:tag1_id]).take
    tag2 = Tag.where(:id =>params[:tag2_id]).take
    tag3 = Tag.where(:id =>params[:tag3_id]).take
    tag1.content = params[:tag1]
    tag1.save
    tag2.content = params[:tag2]
    tag2.save
    tag3.content = params[:tag3]
    tag3.save

    
    #render :text =>""
    
     redirect_to "/cafe/cafedetail?hash=#{edit.cafehash}"
  end

  def cafecreate

    cafe = Cafe.new
    cafe.name = params[:cafename]
    cafe.thumnail = params[:thumbnail]
    cafe.image = params[:cafeimage]
    cafe.signaturemenu = params[:signaturemenu]
    cafe.introduction = params[:intro_detail]
    cafe.cafehash = SecureRandom.hex(11)
    cafe.user_id = current_user.id
    cafe.address_road = params[:buyer_addr] + " " + params[:address_detail]
    cafe.address = params[:address_jibun]
    cafe.latitude = params[:latitude]
    cafe.longitude = params[:longitude]
    cafe.cafecontact = params[:cafecontact]
    cafe.webinfo_address = params[:webinfo_adderess]
    cafe.facebook_address = params[:facebook_address]
    cafe.instagram_adderess = params[:instagram_adderess]
    cafe.blog_address = params[:blog_adderess]
    cafe.machine = params[:machine]
    cafe.grinder = params[:grinder]
    cafe.bean = params[:beans]
    cafe.brewing_method = params[:brewing_method]
    cafe.business_hour = params[:opening_time]+"~"+params[:closing_time]
    if params[:meal_available] == 'checked'
      cafe.meal_available = true
    else
      cafe.meal_available = false
    end
    if params[:parking] == 'checked'
      cafe.parking = true
    else
      cafe.parking = false
    end
    if params[:wifi] == 'checked'
      cafe.wifi = true
    else
      cafe.wifi = false
    end
    if params[:sidemenu] == 'checked'
      cafe.sidemenu = true
    else
      cafe.sidemenu = false
    end
    if params[:animal_available] === 'checked'
      cafe.animal_available = true
    else
      cafe.animal_available = false
    end
    if params[:in_house_roasting] == 'checked'
      cafe.in_house_roasting  = true
    else
      cafe.in_house_roasting = false
    end
    if params[:today_business_check] == 'checked'
      cafe.today_business_check = true
    else
      cafe.today_business_check = false
    end
    if params[:smoke] == 'checked'
      cafe.smoke = true
    else
      cafe.smoke = false
    end
    cafe.save

    Tag.create(cafe_id: cafe.id, content: params[:cafename])
    Tag.create(cafe_id: cafe.id, content: params[:signaturemenu])
    Tag.create(cafe_id: cafe.id, content: params[:address_jibun])
    Tag.create(cafe_id: cafe.id, content: params[:tag1])
    Tag.create(cafe_id: cafe.id, content: params[:tag2])
    Tag.create(cafe_id: cafe.id, content: params[:tag3])


    payinfo = Payinfo.new
    payinfo.pay_method = params[:pay_method]
    payinfo.merchant_uid = params[:merchant_uid]
    payinfo.name = params[:name]
    payinfo.paid_amount = params[:paid_amount].to_i
    payinfo.pg_provider = params[:pg_provider]
    payinfo.pg_tid = params[:pg_tid]
    payinfo.apply_num = params[:apply_num]
    payinfo.vbank_num = params[:vbank_num]
    payinfo.vbank_name = params[:vbank_name]
    payinfo.vbank_holder = params[:vbank_holder]
    payinfo.vbank_date = params[:vbank_date]
    payinfo.user_id = current_user.id
    payinfo.cafe_id = Cafe.last.id
    payinfo.paid_at = DateTime.now.in_time_zone(9).strftime("%Y-%m-%d %H:%M:%S")
    payinfo.pay_status = params[:pay_status]
    payinfo.save
    
    # render :text => ""
    redirect_to "/cafe/cafedetail?hash=#{cafe.cafehash}"
    # render :js => "window.location = '/cafe/cafedetail?hash=#{cafe.cafehash}'"
  end
  
  def caferegister
    @user = User.where(id: current_user.id).take

  end

  def cafedelete
    cafe = Cafe.find(params[:id])
    unless cafe.posts.nil?
      for i in 0.. cafe.posts.size-1
        cafe.posts[i].remove_image!
      end
    end
    cafe.remove_thumnail!
    cafe.remove_image!
    cafe.destroy
    redirect_to '/'
  end
  
  def add_post

    if current_user
        @cafe = Cafe.where(:cafehash => params[:cafehash]).take
        post = Post.new
        post.user_id = current_user.id
        post.content = params[:postcontent]
        post.image = params[:postimage]
        post.address = @cafe.name
        post.cafe_id = @cafe.id
        post.writtentime = DateTime.now.in_time_zone(9).strftime("%Y-%m-%d %H:%M:%S")
        post.hashstr = SecureRandom.hex(11)
        post.score = params[:rating].to_i
        post.save
        count = params[:count].to_i
        for i in 0..count-1
          unless params[i.to_s] == ""
            Tag.create(:content =>params[i.to_s], 
                       :counting => 0, 
                       :cafe_id => @cafe.id,
                       :post_id => post.id)
          end 
        end
        redirect_to(:back)
    else
        redirect_to "/users/sign_in"
    end
  end

  def add_reply
    @reply = Reply.new
    @reply.content=params[:reply]
    @reply.writtentime=DateTime.now.in_time_zone(9).strftime("%Y-%m-%d %H:%M:%S")
    @reply.user_id = current_user.id
    @reply.post_id = params[:post_id]
    @reply.save
    render :text =>@reply.to_json
  end
  
  def delete_post
    post = Post.find(params[:id])
    post.remove_image!
    post.destroy
    redirect_to(:back)
  end

  def delete_reply
    reply = Reply.where(:id=>params[:reply_id]).take
    reply.destroy
    render :text =>""
  end

  def edit_reply
    reply = Reply.where(:id=>params[:reply_id]).take
    reply.content = params[:reply]
    reply.writtentime = DateTime.now.in_time_zone(9).strftime("%Y-%m-%d %H:%M:%S")
    reply.save
    render :text => reply.to_json
  end

  def show_payinfo
    @user = User.where(id: current_user.id).take
    @cafe = Cafe.where(id: current_user.id).take
  end

  def cafephoto
    @comment = Post.where(:id => params[:image_id]).take
    render :text => ""
  end

  def board_update
    modify = MainBoard.find(params[:id])
    modify.title = params[:board_title]
    modify.image = params[:image]
    modify.searchkeyword_tag = params[:keywordtag]

    modify.save
    redirect_to '/'
  end