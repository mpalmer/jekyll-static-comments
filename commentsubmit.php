<?php

// commentsubmit.php -- Receive comments and e-mail them to someone
// Copyright (C) 2011 Matt Palmer <mpalmer@hezmatt.org>
//
//  This program is free software; you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3, as
//  published by the Free Software Foundation.
//
//  This program is distributed in the hope that it will be useful, but
//  WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
//  General Public License for more details.
//
//  You should have received a copy of the GNU General Public License along
//  with this program; if not, see <http://www.gnu.org/licences/>


// Format of the date you want to use in your comments.  See
// http://php.net/manual/en/function.date.php for the insane details of this
// format.
$DATE_FORMAT = "Y-m-d H:i";

// Where the comment e-mails should be sent to.  This will also be used as
// the From: address.  Whilst you could, in theory, change this to take the
// address out of the form, it's *incredibly* highly recommended you don't,
// because that turns you into an open relay, and that's not cool.
$EMAIL_ADDRESS = "blogger@example.com";

// The contents of the following file (relative to this PHP file) will be
// displayed after the comment is received.  Customise it to your heart's
// content.
$COMMENT_RECEIVED = "comment_received.html";

/****************************************************************************
 * HERE BE CODE
 ****************************************************************************/

function get_post_field($key, $defaultValue = "")
{
	return (isset($_POST[$key]) && !empty($_POST[$key])) ? $_POST[$key] : $defaultValue;
}

function filter_name($input)
{
	$rules = array( "\r" => '', "\n" => '', "\t" => '', '"'  => "'", '<'  => '[', '>'  => ']' );
	return trim(strtr($input, $rules));
}

function filter_email($input)
{
	$rules = array( "\r" => '', "\n" => '', "\t" => '', '"'  => '', ','  => '', '<'  => '', '>'  => '' );
	return strtr($input, $rules);
}


$EMAIL_ADDRESS = filter_email($EMAIL_ADDRESS);
$COMMENTER_NAME = filter_name(get_post_field('name', "Anonymous"));
$POST_TITLE = get_post_field('post_title', "Unknown post");

$subject = "Comment from $COMMENTER_NAME on '$POST_TITLE'";

// NOTE: Uses the "blog owner's" email address for the "From:" field, 
// not the email address of the commenter.
$headers = "From: $COMMENTER_NAME <$EMAIL_ADDRESS>\r\n";

$post_id = $_POST["post_id"];
unset($_POST["post_id"]);
$message = "post_id: $post_id\n";
$message .= "date: " . date($DATE_FORMAT) . "\n";

foreach ($_POST as $key => $value) {
	if (strstr($value, "\n") != "") {
		// Value has newlines... need to indent them so the YAML
		// looks right
		$value = str_replace("\n", "\n  ", $value);
	}
	// It's easier just to single-quote everything than to try and work
	// out what might need quoting
	$value = "'" . str_replace("'", "''", $value) . "'";
	$message .= "$key: $value\n";
}

if (mail($EMAIL_ADDRESS, $subject, $message, $headers))
{
	include $COMMENT_RECEIVED;
}
else
{
	echo "There was a problem sending the comment. Please contact the site's owner.";
}
