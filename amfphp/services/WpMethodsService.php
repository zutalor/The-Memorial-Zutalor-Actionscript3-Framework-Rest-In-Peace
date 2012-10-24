<?php

/**
* FlashPress - WordPress-Amf Integration
*
* You will need to have a valid crossdomain.xml file, on the domain that you intend to connect to Wordpress. If not, you will receive security errors from the FlashPlayer.
*
* When using this class within a service browser (AMFPHP), read this post for how to pass values: http://wadearnold.com/blog/?p=22
*
* Passes back VO objects for most service calls. Each VO  maps the wp database structure to itself. The WpPostCategoryVO has a custom structure, with an addition for a permalink entry. The WpPostVO object is used for both pages, posts and attachments. VO Mapping is accomplished via the use of $_explicitType within each VO Class.
* Note, that to write to the wordpress database you must declare the constant('WPWRITEABLE') as 'true' within your gateway file. You must also link to the wp_admin file. Each method that writes to the Wordpress database checks for the
* existence of the 'WPWRITEABLE' constant and will only run if its both been defined and has been set to true.
*
*
 * @author Dale Sattler
 * @email dale@thereformation.co.nz
 *
 * @link http://www.blog.thereformation.co.nz
 * @version 0.7
 * @copyright (c) Dale Sattler - thereformation 2010
 * @package flashpress
 */

//imports
require_once('vo/WpPostVO.php');
require_once('vo/WpBlogRollVO.php');
require_once('vo/WpCommentVO.php');
require_once('vo/WpTermVO.php');
require_once('vo/WpCategoryVO.php');
require_once('vo/WpPostCategoryVO.php');
require_once('vo/WpAttachmentVO.php');
require_once('vo/WpOptionVO.php');
require_once('vo/WpUserVO.php');
require_once('vo/WpBlogInfoVO.php');
require_once('vo/WpMetaVO.php');
require_once('vo/WpPostCountVO.php');
require_once('vo/WpSearchVO.php');

/**
 * FlashPressService
 * Class contains methods for reading from and optionally writing to a Wordpress Install.
 * If you are writing to your Wordpress install, it is important that you understand the security implications of doing so.
 *
 **/

class WpMethodsService  {	
	
	function WpMethodsService(){}
	
	/*************************************************************************************
	***
	***	BEGIN PUBLIC METHODS
	**
	*************************************************************************************/	
	
	/**
	 * This function posts a comment
	 * @link http://codex.wordpress.org/Function_Reference/wp_new_comment
	 * @param	integer		$postId			ID of post / page / 
	 * @param	string		$author			
	 * @param	string		$email			
	 * @param	string		$url			
	 * @param	string		$content		
	 * @return	false						False on failure, mixed on success.
	 */
		
	public function newComment($postId, $author, $email, $url, $content)
	{
		$time = ""; // probably pass in the time, yet, wp will default to the install time

		$data = array(
			'comment_post_ID' => $postId,
			'comment_author' => $author,
			'comment_author_email' => $email,
			'comment_author_url' => $url,
			'comment_content' => $content,
			'comment_type' => '', 
			'comment_parent' => 0,
			'user_id' => 0,
			'comment_author_IP' => $_SERVER['REMOTE_ADDR'],
			'comment_agent' => $_SERVER['HTTP_USER_AGENT'],
			'comment_date' => $time,
			'comment_approved' => 0,
		);
		wp_new_comment($data);
		return true;
	}
	  
	/*************************************************************************************
	***	METHODS THAT READ FROM THE WORDPRESS DATABASE - THESE ARE SECURE
	*************************************************************************************/	
	 /**
	* This function simply counts the posts / pages currently contained within your Wordpress install.
	* This method is a proxy for the wp_count_posts() Wordpress method.
	* @link http://codex.wordpress.org/Function_Reference/wp_count_posts
	* @param 	string		$type		The type of post you want to count. Defaults to "post" Accepts any valid post type.
	* @return	integer					
	*/	
	  public function countPosts($type='post'){
	  	$count = wp_count_posts($type, 'readable');
	  	$countVO = new WpPostCountVO();
	  	$countVO -> {'publish'} = $count->publish;
	  	$countVO -> {'draft'} = $count->draft;
	  	$countVO -> {'private_post'} = $count->private;
	  	$countVO -> {'pending'} = $count->pending;
	  	$countVO -> {'future'} = $count->future;

	  	return $countVO;
	  }
	  
	 
	public function countPostsInCategories($catslugs = '') {
		global $wpdb;

		$post_count = 0;
		$slug_where = '';
		$catslugs_arr = split(',', $catslugs);

		foreach ($catslugs_arr as $catslugkey => $catslug) {
			if ( $catslugkey > 0 ) {
				$slug_where .= ', ';
			 }

			$slug_where .= "'" . trim($catslug) . "'";
		}

		$slug_where = "cat_terms.slug IN (" . $slug_where . ")";

		$sql =	"SELECT	COUNT( DISTINCT cat_posts.ID ) AS post_count " .
			"FROM 	" . $wpdb->term_taxonomy . " AS cat_term_taxonomy INNER JOIN " . $wpdb->terms . " AS cat_terms ON " .
					"cat_term_taxonomy.term_id = cat_terms.term_id " .
				"INNER JOIN " . $wpdb->term_relationships . " AS cat_term_relationships ON " .
					"cat_term_taxonomy.term_taxonomy_id = cat_term_relationships.term_taxonomy_id " .
				"INNER JOIN " . $wpdb->posts . " AS cat_posts ON " .
					"cat_term_relationships.object_id = cat_posts.ID " .
			"WHERE 	cat_posts.post_status = 'publish' AND " .
				"cat_posts.post_type = 'post' AND " .
				"cat_term_taxonomy.taxonomy = 'category' AND " .
				$slug_where;

		$post_count = $wpdb->get_var($sql);
		
		$countVO = new WpPostCountVO(); //total hack here...we're only counting published status
	  	$countVO -> {'publish'} = (int)($post_count);
	  	$countVO -> {'draft'} = 0;
	  	$countVO -> {'private_post'} = 0;
	  	$countVO -> {'pending'} = 0;
	  	$countVO -> {'future'} = 0;

		return $countVO; 

	}
	 
	  
	/**
	* This function returns a post via its ID.
	* This method is a proxy for the get_post() Wordpress method.
	* @link http://codex.wordpress.org/Function_Reference/get_post
	* @param 	integer		$postId		Representing ID of post to retrieve.
	* @return WpPostVO  
	* @throws Exception
	*/	
	public function getPost($postId){
		$post = get_post($postId, ARRAY_A);
		if($post==false){
			$this->showErrors('Problem getting post. Looks like the ID passed is not in the database.', 1 );
		}else{
			$p = $this->parseWpPostData($post);
			return $p;
		}
	}
	
	/**
	* This function returns a post/ pages attachments or children. A useful method for returning the images attached to a particular post.
	* This method is a proxy for the get_children Wordpress method.
	* @link http://codex.wordpress.org/Function_Reference/get_children
	* @param 	integer		$postId		Representing ID of post to get attachments from.
	* @return WpAttachmentVO  
	* @throws Exception
	*/	
	public function getPostAttachments($postId){
			$args = array(
			'post_type' => 'attachment',
			'numberposts' => -1,
			'post_status' => null,
			'post_parent' => $postId
			); 
			
			$attachments =& get_children( $args );
			$attachmentsArr = array();
		
			if ( empty($attachments) ) {
				// no attachments here
				$this->showErrors('Problem getting post attachments. Looks like the post ID was incorrect, or it has no attachments.', 1 );
			} else {
				foreach ( $attachments as $attachment_id => $attachment ) {
					array_push($attachmentsArr, $attachment);
				}
				$p = $this->parseWpMediaData($attachmentsArr);
				return $p;
			}
	}
	
	/**
	* This function returns the featured image of a post, if it has one. Will throw an error if Wordpress version is too low to support
	* post thumbnails.
	* This method is a proxy for get_post_thumbnail_id method.
	* @link http://codex.wordpress.org/Function_Reference/get_post_thumbnail_id
	* @param 	integer		$postId		Representing ID of post to get the featured image from.
	* @return WpAttachmentVO
	* @throws Exception if no image is found, or Wordpress does not support post thumbnails.
	*/	
	public function getPostFeatured($postId){
	//check if we have a post thumbnail function first
	if (function_exists('add_theme_support')) {
		//check if we have a post thumbnail present
			if ( has_post_thumbnail($postId) ) {
				// the current post has a thumbnail?
				$thumb_id = get_post_thumbnail_id( $postId );
				$myPost = get_post($thumb_id, ARRAY_A);
				$p = $this->parseWpMediaData($myPost);
				return $p;	
			}else{
				$this->showErrors('Problem getting posts featured image, it probably does not have a featured image.', 1 );
			}
		}else{
			$this->showErrors('Featured images not supported by this version of Wordpress.', 1 );
		}
	}
		
	/**
	 * This function return a posts. As this method is a wrapper for get_posts(), you can return any post type with it. Although, attachments seems
	 * buggy.
	 * This method is a proxy for the get_posts() Wordpress method.
	 * @link http://codex.wordpress.org/Template_Tags/get_posts
	 * @param 	string		$args		Query string format of options. Review wordpress documentation for what can be passed here.
	 * @return 	array					Containing WpPostVO  Objects(s).
	 */	
	
	public function getPosts($args){
		$myPosts  = get_posts($args);
   		$p = $this->parseWpPostData($myPosts);
		return $p;	
	}
	
	 /**
	 * Get a single post or pages data by it's title. Returns single WpPostVO object. Only published posts/pages are returned.
	 * @param string		$postTitle		Name of post / page  to retrieve. This is not it's slug!
	 * @return WpPostVO
	 */
	 	 
	public function getPostOrPageByTitle($postTitle, $cat_name="") {
		global $wpdb;
		
		if ($cat_name='')
			$sql = "SELECT * FROM $wpdb->posts WHERE post_status='publish' AND post_title='$postTitle'";
		else
			$sql = "SELECT * FROM $wpdb->posts WHERE post_status='publish' AND post_title='$postTitle' AND category_name='$cat_name'";
		$rawpost = $wpdb->get_results($sql);
		$post = get_post($rawpost[0]->ID, ARRAY_A);
		$p = $this->parseWpPostData($post);
		return $p;
	}
	
	public function getPageByTitle($postTitle) {
		global $wpdb;
		
		$sql = "SELECT * FROM $wpdb->posts WHERE post_status='publish' AND post_title='$postTitle'";
		$rawpost = $wpdb->get_results($sql);
		$post = get_post($rawpost[0]->ID, ARRAY_A);
		$p = $this->parseWpPostData($post);
		return $p;
	}		

	/**
     * Retrieve media (attachments) from Wordpress. Can retrieve any valid media type
     * you have uploaded into Wordpress. This method is essentially a wrapper for 'get_children()'. 
     * Documentation for this Wordpress method can be found here: http://codex.wordpress.org/Function_Reference/get_children
     *
     * @param  string						  	$mediaType  OPTIONAL Type of media to retrieve. Default is
     *                                                 		'image'. You must pass media types via their mime-type.
     *														Valid mime-types are listed here: http://en.wikipedia.org/wiki/Internet_media_type
     * @param  integer                          $limit    	OPTIONAL Defines how many attachments to return. Default (-1) is to return all!
     * @param  string              				$customArgs OPTIONAL Custom arguments for accessing attachments. See here for what
     *														this method supports: http://codex.wordpress.org/Function_Reference/get_children
     * @return WpAttachmentVO
     */
	public function getMedia($mediaType='image', $limit=-1, $customArgs=''){
		$query = (empty($customArgs)) ? 'post_type=attachment&post_mime_type='.$mediaType.'&post_parent=null&post_status=inherit&numberposts='.$limit : $customArgs;
		$attachments =&get_children($query, ARRAY_A );
 		//push into array, as get children returns an empty entry for all children, regardless of params
   		$attachmentsArr = array();
	   		foreach($attachments as $att){
				array_push($attachmentsArr, $att);
			}
		$p = $this->parseWpMediaData($attachmentsArr);
		return $p;
	}

	/**
	 * This function returns an array of bookmarks found in the Blogroll > Manage Blogroll panel as a collection of WpBlogRollVO Objects. 
	 * look here: http://codex.wordpress.org/Function_Reference/get_bookmarks
	 * @param string		$args  		Various arguments as a query string - eg 'orderby=name', as per documentation 
	 * 									here: http://codex.wordpress.org/Function_Reference/get_bookmarks
	 * @return WpBlogRollVO
	 */	
	public function getBookmarks($args) {
		$myLinks = get_bookmarks($args);
		$bm = $this->parseWpLinkData($myLinks);
		return $bm;	
	}
		
	/**
	 * This function returns information about your blog. It simply calls the Wordpress method 'get_bloginfo()'. You are able to request a 
	 * single individual value or leave the arguments blank to receive all blog info.See here: http://codex.wordpress.org/Function_Reference/get_bloginfo
	 * @param string		$show		OPTIONAL What options to get in particular from Wordpress, or if empty, all
	 *									options are returned. See here: http://codex.wordpress.org/Function_Reference/get_bloginfo
	 * @return WpBlogInfoVO or string
	 */		
	public function getBlogInfo($show="") {
		if($show==""){
	        $info = new WpBlogInfoVO();
			foreach($info as $key => &$value) {
			    $value = get_bloginfo($key);
			}
			 return $info;
		 }else{
		 	return get_bloginfo($show);
		 }	
	}
	/**
	 * This function returns the tags associated with a post or posts. Chances are, some tags will appear twice if you are 
	 * requesting tag information from multiple posts / pages!
	 * @link http://codex.wordpress.org/Function_Reference/wp_get_object_terms
	 * @param string	$postIds	Comma delimited string of post id's to access tags from. eg; '341,200'.	
	 * @return array Containing WpTermVO objects.
	 *							
	 */	
	public function getTagsByPostId($postIds){
		$args = explode(",", $postIds);
		$myTags =  wp_get_object_terms($args, 'post_tag');
		$bm = $this->parseWpTermData($myTags);
		return $bm;
	}
	
	/**
	 * This function returns the categories associated with a post/page or posts/pages. It removes duplicate categories that appear across posts
	 * from the return result.
	 * @link http://codex.wordpress.org/Function_Reference/get_term
	 * @param string	$postIds	REQUIRED Comma delimited string of post id's to access categories from. eg; '341,200'.
	 * @return array Containing WpTermVO objects.	
	 *							
	 */	
	public function getCategoriesByPostId($postIds){
		$args = explode(",", $postIds);
		$custMetaArr = array();
		foreach ($args as $v1) {
			$cat = wp_get_post_categories( $v1);
			array_push( $custMetaArr, $cat );
		}
			
		$custMetaArr = array_unique($custMetaArr);
		$catIds = array();
		foreach($custMetaArr[0] as $v2){
			$term = get_term($v2, 'category');
			array_push( $catIds, $term );
		}
		$bm = $this->parseWpTermData( $catIds);
		return $bm;
	}

	
	/**
	 * This function returns the wordpress sites categories. See Wordpress codex for detailed information on method parameters.
	 * @link http://codex.wordpress.org/Function_Reference/get_terms
	 * @param string	$args	OPTIONAL How to massage the return of categories from from Wordpress. If empty
	 *							defaults are used. http://codex.wordpress.org/Function_Reference/get_categories
	 * @return array Containing WpTermVO objects.
	 */		
	public function getCategories($args=""){
		$cats = get_terms('category', $args);
		$cm = $this->parseWpTermData($cats);
		return $cm;
	}
	
	/**
	 * This function returns the wordpress sites terms, allowing for standard wordpress terms and custom taxonomies. 
	 * @link http://codex.wordpress.org/Function_Reference/get_terms
	 * @param string	$term	What term to retrieve, eg 'post_tag'.To request multiple taxonomies, pass a comma delimited string to
	 *							this method eg; 'my-custom-taxonomy,post_tag'
	 * @param string	$args	Arguments acceptable to Wordpress 'get_terms()', as seen here: http://codex.wordpress.org/Function_Reference/get_terms
	 * @return array Containing WpTermVO Objects.
	 */	
	public function getTerms($terms, $args=""){
		$termsToGet = explode(",", $terms);
		$myTags =  get_terms($termsToGet, $args);
		$bm = $this->parseWpTermData($myTags);
		return $bm; 
	}
	
	/**
	 * This function returns a 'tag cloud', or more correctly, a taxonomy cloud of terms in the Wordpress database. 
	 * This is simply a convienience method as the functionality exposed here can be created using the 'getTerms()' method. 
	 * The advantage of this method is that you do not need to know the term names.
	 * @link http://codex.wordpress.org/Function_Reference/get_terms
	 * @param boolean	$allTerms	Whether or not to return all terms (true) or only tags and categories (false). Default is true.
	 * @param string	$args		Arguments acceptable to the Wordpress 'get_terms()' method, as seen here: http://codex.wordpress.org/Function_Reference/get_terms
	 * @return array Containing WpTermVO Objects.
	 */	
	public function getTagCloud($allTerms=true, $args=""){
		global $wpdb;
		$termsArr = array();
		if($allTerms==true) {
			$sql = "select DISTINCT taxonomy from $wpdb->term_taxonomy";
			$terms = $wpdb->get_results($sql);
			foreach ($terms as $v1) {
			    foreach ($v1 as $v2) {
			        array_push($termsArr, $v2);
			    }
			}
		}else{
			$termsArr = array('post_tag', 'category');;
		}

		$myTags =  get_terms($termsArr, $args);
		$tc = $this->parseWpTermData($myTags);
		return $tc; 
	}
	
	/**
	 * This function returns the current term names contained within Wordpress. It includes standard Wordpress terms such as 'category' but will also
	 * list custom taxonomies either created manually, or via a pluggin. Will return an array of term names, which can be used by other methods.
	 * This method is useful if you do not know all the terms contained within your Wordpress install. Be aware that internally this method simply calls a DISTINCT
	 * select on the Wordpress taxonomy table.
	 * @return array Containing term names, eg ['post_tag', 'category'];
	 */	
	public function findTerms(){
		global $wpdb;
		$sql = "select DISTINCT taxonomy from $wpdb->term_taxonomy";
		$terms = $wpdb->get_results($sql);
		$termsArr = array();
		foreach ($terms as $v1) {
		    foreach ($v1 as $v2) {
		        array_push($termsArr, $v2);
		    }
		}
		return $termsArr;
	}
	
	/**
	 * This function returns current metadata for a post / page. If you wish to access all metadata do not pass in a value
	 * for $key. Otherwise, if you know the metadata field you want to access a value from, pass in a value for $key.
	 * This method is a proxy for the get_post_custom() and get_post_meta() Wordpress methods.
	 * @link http://codex.wordpress.org/Function_Reference/get_post_custom
	 * @param 	integer		$postId		Representing ID of post to retrieve metadata from.
	 * @param 	string		$key		Representing what particular custom meta field to access. 
	 * @return array 	Containing WpMetaVO object(s).  
	 */	
	
	public function getPostMeta($postId, $key=''){
		$custMetaArr = array();
		if(empty($key)) {
			$meta  = get_post_custom($postId);
			$keys =  array_keys($meta);
			$vals =  array_values($meta);
	
			$i = 0;
			foreach ($keys as $v1) {
				$metaVO = new WpMetaVO();
				$metaVO -> {'meta_name'} = $v1;
				$metaVO -> {'meta_value'} = $vals[$i];
			   	array_push( $custMetaArr, $metaVO );
			   	$i ++;
			}
		}else{
			$metaVO = new WpMetaVO();
			$metaVO -> {'meta_name'} = $key;
			$metaVO -> {'meta_value'} = get_post_meta($postId, $key, true);
			array_push( $custMetaArr, $metaVO );
		}	
        return 	$custMetaArr;
	}
	
	/**
	 * This function returns current comments within your Wordpress install. Use the method arguments outlined at the Wordpress
	 * Codex for filtering the correct values that you need. Eg to get approved comments for post id 15; 'status=approve&post_id=15'
	 * This method is a proxy for the get_comments() Wordpress method.
	 * @link http://codex.wordpress.org/Function_Reference/get_comments
	 * @param 	string		$args		Query string, as defined here; http://codex.wordpress.org/Function_Reference/get_comments
	 * @return 	array 					Containing WpCommentVO object(s).  
	 */		
	public function getComments($args=''){
		$myComments =  get_comments($args);
		$com = $this->parseWpCommentData($myComments);
		return $com; 
	}
	
	
		/**
	 * This function returns current comments within your Wordpress install. Use the method arguments outlined at the Wordpress
	 * Codex for filtering the correct values that you need. Eg to get approved comments for post id 15; 'status=approve&post_id=15'
	 * This method is a proxy for the get_comments() Wordpress method.
	 * @link http://codex.wordpress.org/Function_Reference/get_comments
	 * @param 	string		$args		Query string, as defined here; http://codex.wordpress.org/Function_Reference/get_comments
	 * @return 	array 					Containing WpCommentVO object(s).  
	 */		
	public function postComment($args=''){
		$myComments =  get_comments($args);
		$com = $this->parseWpCommentData($myComments);
		return $com; 
	}
	
	/**
	 * This is still a work in progress.
	 * This function searches the wordpress database. It currently only returns results from posts, pages and optionally attachments. In all
	 * instances, the content must be published. Only published content is searched, or if you are searching attachments, posts with a status of 'inherit' are also searched. 
	 * Interally this method uses a custom SQL query, and the MYSQL match method. View here for more detail on this method: http://dev.mysql.com/doc/refman/5.1/en/fulltext-search.html
	 * @param 	string		$keywords			Query string, comma delimited keywords to search for.
	 * @param 	boolean		$searchAttachments	Boolean value indicating whether or not to search attachments as well. Default is false.
	 * @return 	array 					Containing WpPostVO object(s). If no content is found, returns a string "Nothing found". 
	 */		
	public function search($keywords, $searchAttachments = false){
		global $wpdb;
		$query = mysql_real_escape_string($keywords);
		if($searchAttachments) {
			$sql = "SELECT *, MATCH(post_content, post_title) AGAINST ('$query' IN BOOLEAN MODE ) AS score FROM wp_posts WHERE MATCH(post_content, post_title) AGAINST('$query' IN BOOLEAN MODE) AND (post_type = 'post' OR post_type = 'page' OR post_type = 'attachment') AND (post_status = 'publish' OR post_status = 'inherit') ORDER BY score DESC";
		}else{
				$sql = "SELECT *, MATCH(post_content, post_title) AGAINST ('$query' IN BOOLEAN MODE ) AS score FROM wp_posts WHERE MATCH(post_content, post_title) AGAINST('$query' IN BOOLEAN MODE) AND (post_type = 'post' OR post_type = 'page') AND post_status = 'publish' ORDER BY score DESC";
		}
		
		$results = $wpdb->get_results($sql);
		
		if(count($results) > 0 ){
			$p = $this->parseWpSearchData($results);
			return $p;	
		}else{
			return "Nothing found";
		}
	}
	

	/**
	 * This function returns a user via their user id. Throws exception if user not found.
	 * This method is a proxy for the get_userdata() Wordpress method.
	 * @link http://codex.wordpress.org/Function_Reference/get_userdata
	 * @param 	integer		$userId		Users ID
	 * @return  object 		WpUserVO Object.  
	 */		
	public function getUserById($userId) {
		global $wpdb;
		$sql = "select * from $wpdb->users WHERE id='$userId'";
		$terms = $wpdb->get_results($sql);
		
		if($terms==false){
			$this->showErrors('Problem getting user. Username would appear to not exist', 1 );
		}else{
			$myUserData =  get_userdata($userId);
			$use = $this->parseWpUserData($myUserData);
			return $use;
		}
	}
	
	/**
	 * This function returns a user via their user login name. Throws exception if user not found.
	 * This method is a proxy for the get_userdatabylogin() Wordpress method.
	 * @link http://codex.wordpress.org/Function_Reference/get_userdatabylogin
	 * @param 	string		$userLogName	Users login name
	 * @return  object 		WpUserVO Object.  
	 */		
	public function getUserByLoginName($userLogName) {
		if (get_userdatabylogin( $userLogName )==false){
			$this->showErrors('Problem getting user. Username would appear to not exist', 1 );
		}else{
		 	$myUserData =  get_userdatabylogin( $userLogName );
			$use = $this->parseWpUserData($myUserData);
			return $use;
		}
	}
	
	/**
	 * This function returns a particular metadata value from a users metadata. 
	 * This method is a proxy for the get_usermeta() Wordpress method.
	 * @link http://codex.wordpress.org/Function_Reference/get_usermeta
	 * @param 	integer		$userId		Id of user to access metadata from
	 * @param	string		$metaKey	Metadata key to obtain value from
	 * @return 	string	 	Containing value of metadata key passed to method.  
	 */		
	public function getUserMetadata($userId, $metaKey) {
		return get_usermeta($userId, $metaKey);
	}
	
	/*************************************************************************************
	***	END PUBLIC METHODS
	*************************************************************************************/	
	/*************************************************************************************
	***	PRIVATE HELPER METHODS
	*************************************************************************************/	
	
	private function parseWpPostData($postData) {				
			if(is_int($postData['ID'])){
				$post = new WpPostVO();
		    	foreach ($postData as $akey => $aval) {
		            $post -> {$akey} = $aval;
		        }
		        $post -> {'permalink'} = get_page_link($postData['ID']);
	        	return $post;
			}else{
				$posts = array();
				for($i = 0; $i < sizeof($postData); ++$i) {
	        		$post = new WpPostVO();
		    		foreach ($postData[$i] as $akey => $aval) {
		            	$post -> {$akey} = $aval;
		        	}
		        	
		        	$post -> {'permalink'} = get_page_link($postData[$i]->ID);
	        		array_push( $posts, $post );
				}
				return $posts;
			}
	}
	
	
	private function parseWpSearchData($postData) {				
			if(is_int($postData['ID'])){
				$post = new WpSearchVO();
		    	foreach ($postData as $akey => $aval) {
		            $post -> {$akey} = $aval;
		        }
		        $post -> {'permalink'} = get_page_link($postData['ID']);
		        $post -> {'score'} = $postData['score'];
	        	return $post;
			}else{
				$posts = array();
				for($i = 0; $i < sizeof($postData); ++$i) {
	        		$post = new WpSearchVO();
		    		foreach ($postData[$i] as $akey => $aval) {
		            	$post -> {$akey} = $aval;
		        	}
		        	
		        	$post -> {'permalink'} = get_page_link($postData[$i]->ID);
		        	$post -> {'score'} = $postData[$i]->score;
	        		array_push( $posts, $post );
				}
				return $posts;
			}
	}
	
	
	private function parseWpMediaData($postData) {	
			if(is_int($postData['ID'])){
				$post = new WpAttachmentVO();
		    	foreach ($postData as $akey => $aval) {
		            $post -> {$akey} = $aval;
		        }
		        $post -> {'media_url'} = wp_get_attachment_url($postData['ID']);
		        $post -> {'permalink'} = get_page_link($postData['ID']);
	        	return $post;
			}else{
				$posts = array();
				for($i = 0; $i < sizeof($postData); ++$i) {
	        		$post = new WpAttachmentVO();
		    		foreach ($postData[$i] as $akey => $aval) {
		            	$post -> {$akey} = $aval;
		        	}

		        	$post -> {'media_url'} = wp_get_attachment_url($postData[$i]->ID);
		        	$post -> {'permalink'} = get_page_link($postData[$i]->ID);
	        		array_push( $posts, $post );
				}
				return $posts;
			}	
	}
	
	private function parseWpLinkData($linkData) {			
			$posts = array();
        	for($i = 0; $i < sizeof($linkData); ++$i) {
        		$post = new WpBlogRollVO();
	    			foreach ($linkData[$i] as $akey => $aval) {
	            		$post -> {$akey} = $aval;
	        		}
        		array_push( $posts, $post );
			}
		    return $posts;	
	}
	
	private function parseWpTermData($termData) {			
			$tags = array();
        	for($i = 0; $i < sizeof($termData); ++$i) {
        		$tag = new WpTermVO();
	    			foreach ($termData[$i] as $tkey => $tval) {
	            		$tag -> {$tkey} = $tval;
	        		}
        		array_push( $tags, $tag );
			}
		    return $tags;	
	}
	
	private function parseWpCommentData($commentData) {			
			$comments = array();
        	for($i = 0; $i < sizeof($commentData); ++$i) {
        		$comment = new WpCommentVO();
	    			foreach ($commentData[$i] as $akey => $aval) {
	            		$comment -> {$akey} = $aval;
	        		}
        		array_push( $comments, $comment );
			}
		    return $comments;	
	}
	
	private function parseWpUserData($userData) {		

		    for($i = 0; $i < sizeof($userData); ++$i) {
        		  $user = new WpUserVO();
				  $user -> user_id = $userData -> ID;	  
				  $user -> user_login = $userData-> user_login;
				  $user -> user_nicename = $userData -> user_nicename;
				  $user -> user_email = $userData -> user_email;
				  $user -> user_url = $userData -> user_url;
				  $user -> user_status = $userData -> user_status;
				  $user -> user_display_name = $userData -> display_name;
				  $user -> user_registered = $userData -> user_registered;
				  $user -> user_pass = $userData -> user_pass;
				  $user -> user_num_posts = get_usernumposts($userData->ID);
				  $user -> user_activation_key = $userData -> user_activation_key;
				  $user -> description = $userData -> description;
				  $user -> nickname = $userData -> nickname;
				  $user -> aim = $userData -> aim;
				  $user -> jabber = $userData -> jabber;
				  $user -> yim = $userData -> yim;
		      }
        		
		   		return $user;	
		  }
	

	//private method for showing some errors
	private function showErrors($message, $errorCode) {
		throw new Exception($message, $errorCode);
	}
	
}// END class 
?>