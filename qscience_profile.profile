<?php
/**
 * @file
 * Provides an option to select patterns to be executed during the site installation.
 *
 * Issues:
 *  - Prepare request to have codemirror in the whitelist: http://drupal.org/node/1945806
 * 
 * @TO-DO
 *  - Disable reporting of projects that are in the distribution, but only
 *    if they have not been updated manually.
 *    See http://drupalcode.org/project/commerce_kickstart.git/blob/HEAD:/commerce_kickstart.profile (l.171)
 *  - themes/shiny can be fetched via drupal-org.make file
 *    
 */

/**
 * Implements hook_install_tasks().
 *
 */
function qscience_profile_install_tasks() {
  $tasks = array();

  // Add a page to send the public key to the PDF server
  $tasks['qscience_profile_pdfparser_settings_form'] = array(
      'display_name' => st('PDF Parser'),
      'type' => 'form',
  );
  
  // Add a page to allow the user to configure the QTR algorithm
  $tasks['qscience_profile_qtr_settings_form'] = array(
      'display_name' => st('Quality, Trust and Reputation'),
      'type' => 'form',
  );
  
  // Add a page to configure Visual Science
  $tasks['qscience_profile_visualscience_settings_form'] = array(
   'display_name' => st('Visual Science'),
      'type' => 'form',
  );
  
  // Add a page to configure D2D
  $tasks['qscience_profile_d2d_settings_form'] = array(
      'display_name' => st('Drupal to Drupal'),
      'type' => 'form',
  );
  
  // Add a page to allow running some patterns
  // Skipping this for the moment
  /*$tasks['qscience_profile_patterns_settings_form'] = array(
      'display_name' => st('Choose Content Types'),
      'type' => 'form',
  );*/
  return $tasks;
}

/**
 * Implements hook_install_tasks_alter().
 */
function qscience_profile_install_tasks_alter(&$tasks, $install_state) {
  //$tasks['install_finished']['function'] = 'qscience_profile_install_finished';
  $tasks['install_select_profile']['display'] = FALSE;
  //$tasks['install_select_locale']['display'] = FALSE;
  //$tasks['install_select_locale']['run'] = INSTALL_TASK_SKIP;

  // The "Welcome" screen needs to come after the first two steps
  // (profile and language selection), despite the fact that they are disabled.
  $new_task['install_welcome'] = array(
      'display' => TRUE,
      'display_name' => st('Welcome'),
      'type' => 'form',
      'run' => isset($install_state['parameters']['welcome']) ? INSTALL_TASK_SKIP : INSTALL_TASK_RUN_IF_REACHED,
  );
  $old_tasks = $tasks;
  $tasks = array_slice($old_tasks, 0, 1) + $new_task + array_slice($old_tasks, 1);

  // Set the installation theme.
  _commerce_kickstart_set_theme('commerce_kickstart_admin');
  // Test if the current task is a batch task.
  if (isset($tasks[$install_state['active_task']]['type']) && $tasks[$install_state['active_task']]['type'] == 'batch') {
    if (!isset($tasks[$install_state['active_task']]['dfp_settings'])) {
      $tasks[$install_state['active_task']]['dfp_settings'] = array();
    }
    // Default to Kickstart_Install dfp unit.
    $tasks[$install_state['active_task']]['dfp_settings'] += array(
        'dfp_unit' => 'Kickstart_Install',
    );
    drupal_add_js('//www.googletagservices.com/tag/js/gpt.js');
    drupal_add_js(array(
    'dfp' => $tasks[$install_state['active_task']]['dfp_settings'],
    ), 'setting');
    drupal_add_js(drupal_get_path('profile', 'commerce_kickstart') . '/js/commerce_kickstart.js');
  }
}

/**
 * Force-set a theme at any point during the execution of the request.
 *
 * Drupal doesn't give us the option to set the theme during the installation
 * process and forces enable the maintenance theme too early in the request
 * for us to modify it in a clean way.
 */
function _commerce_kickstart_set_theme($target_theme) {
  if ($GLOBALS['theme'] != $target_theme) {
    unset($GLOBALS['theme']);

    drupal_static_reset();
    $GLOBALS['conf']['maintenance_theme'] = $target_theme;
    _drupal_maintenance_theme();
  }
}

/**
 * Task callback: shows the welcome screen.
 */
function install_welcome($form, &$form_state, &$install_state) {
  drupal_set_title(st('Welcome to QScience'));
  $qlectives_link = l("QLectives", "http://www.qlectives.eu", array('attributes' => array('target' => '_blank')));
  $message = '<p>' . st('Thank you for choosing QScience, a distribution developed as part of the project !qlectives.', array('!qlectives' => $qlectives_link)) . '</p>';
  $eula = '<p>' . st('QScience is a distributed platform for scientists allowing them to locate or form new communities and quality reviewing mechanisms, which are transparent and promote quality.') . '</p>';
  $items = array();
  $items[] = st('Describe item 1...');
  $items[] = st('Describe item 2...');
  $items[] = st('Describe item N...');
  $items[] = st('@TO-DO: Do we need to inform the users that some of the info will be stored in external servers (i.e.: PDF Parser server)');
  $eula .= theme('item_list', array('items' => $items));
  $eula .= '<p>' . st('!qlectives is supported by the European Commission 7th Framework Programme (FP7) for Research and Technological Development under the Information and Communication Technologies Theme, Future and Emerging Technologies (FET) Proactive, Call 3: ICT-2007.8.4 Science of Complex Systems for socially intelligent ICT (COSI-ICT).', array('!qlectives' => $qlectives_link)) . '</p>';
  $form = array();
  $form['welcome_message'] = array(
      '#markup' => $message,
  );
  $form['eula'] = array(
      '#prefix' => '<div id="eula-installation-welcome">',
      '#markup' => $eula,
  );
  $form['eula-accept'] = array(
      '#title' => st('I agree to the terms'),
      '#type' => 'checkbox',
      '#suffix' => '</div>',
  );
  $form['actions'] = array(
      '#type' => 'actions',
  );
  $form['actions']['submit'] = array(
      '#type' => 'submit',
      '#value' => st("Let's Get Started!"),
      '#states' => array(
          'disabled' => array(
              ':input[name="eula-accept"]' => array('checked' => FALSE),
          ),
      ),
      '#weight' => 10,
  );
  return $form;
}

function install_welcome_submit($form, &$form_state) {
  global $install_state;

  $install_state['parameters']['welcome'] = 'done';
  //$install_state['parameters']['locale'] = 'en';
}

/**
 * Implements hook_form_alter().
 *
 * Allows the profile to alter the site configuration form.
 */
function qscience_profile_form_install_configure_form_alter(&$form, $form_state) {
  // Set a default name for the site
  $form['site_information']['site_name']['#default_value'] = st('QScience Instance');

  // Testing a default country so we can benefit from it on Address Fields. 
  $form['server_settings']['site_default_country']['#default_value'] = 'BE';

  // Hide Update Notifications.
  $form['update_notifications']['#access'] = FALSE;
}

/**
 * Implements qscience_profile_pdfparser_settings_form().
 */
function qscience_profile_pdfparser_settings_form($form, &$form_state, &$install_state) {
  drupal_set_title(st('PDF Parser settings'));
  
  $form['server_url'] = array(
      '#type' => 'textfield',
      '#title' => 'The server URL',
      '#value' => variable_get('pdfparser_server_url'),
  );
  
  $form['submit'] = array(
      '#type' => 'submit',
      '#value' => t('Send my public key to server'),
  );
  return $form;
}

/**
 * Implements qscience_profile_pdfparser_settings_form_submit().
 * Checks that a successful response from the PDF Parser server is received.
 */
function qscience_profile_pdfparser_settings_form_validate($form, &$form_state) {
  $url = $form_state['input']['server_url'];
  $file_headers = @get_headers($url);
  if ($file_headers === FALSE || $file_headers[0] == 'HTTP/1.1 404 Not Found') {
    form_set_error('server_url', t('Invalid url, please check again.'));
  }
}

/**
 * Implements qscience_profile_pdfparser_settings_form_submit().
 * Merges and executes the selected Patterns.
 */
function qscience_profile_pdfparser_settings_form_submit($form, &$form_state) {
  $public = _pdfparser_get_public_path();
  $url = $form_state['input']['server_url'];
  variable_set('pdfparser_server_url', $url);
  $file = $public . variable_get('pdfparser_public_key_path') . 'public_key';
  $post = new stdClass();
  $post->func = 'set_public_key';
  $post->ip = $_SERVER['SERVER_ADDR'];
  $post->public_key = base64_encode(file_get_contents($file));
  
  $ret_pure = do_post_request2($url, json_encode($post));
  $ret = json_decode($ret_pure);
  $pdf_parser_link = l('PDFparser settings', 'admin/pdfparser');
  if (isset($ret->result)) {
    if ($ret->result === 0) {
      drupal_set_message(t('Public key saved succesfully.'));
    }
    elseif ($ret->result === 1) {
      drupal_set_message(t('Cannot save public key at server side. Maybe there is no permission to do that.'), 'error');
      //      dvm($ret_pure);
    }
    else {
      drupal_set_message(t('Invalid server address.'), 'error');
    }
  }
  else {
    drupal_set_message(t("Unrecognized message from server.
    Please check again your server's URL at $pdf_parser_link menu."), 'error');
    drupal_set_message($ret_pure, 'error');
  }
}

/**
 * Implements qscience_profile_qtr_settings_form().
 */
function qscience_profile_qtr_settings_form($form, &$form_state, &$install_state) {
  drupal_set_title(st('Configure QTR algorithm'));
  //$form = array();
  $posttype = array ();
  $default = array();
  $types = qtr_get_itemtype();
  if($types){
    foreach($types as $type){
      $default[]=$type->item_type;
    }
  }
  foreach (node_type_get_types() as $type => $type_obj) {
    $posttype[$type] = $type_obj->name;
  }

  $form['basic'] = array(
      '#type' => 'fieldset',
      '#title' => st('Basic configuration'),
      '#collapsible' => FALSE,
      '#collapsed' => FALSE,
  );
  $form['params'] = array(
      '#type' => 'fieldset',
      '#title' => st('Advanced configuration'),
      '#collapsible' => TRUE,
      '#collapsed' => TRUE,
  );
  $form['basic']['content_type'] = array(
      '#type' => 'checkboxes',
      '#title' => st('Content Types '),
      '#description' => st('These will be the nodes that will be considered for QTR'),
      '#options' => $posttype,
      '#default_value' => $default,
  );
  $form['params']['qtr_delta'] = array(
      '#type' => 'textfield',
      '#title' => t('Delta'),
      '#description' => st('N.B.: if the effective number of AGENTS/ITEMS is lower (i.e. if there are gaps in the input file), the renormalization of the algorithm has to change. Better to have no gaps!'),
      '#default_value' => variable_get('qtr_delta', 0.00000000001),
  );
  
  $actions = qtr_get_actiontype();
  if ($actions) {
    foreach ($actions as $action) {
      $form['params']['qtr_w_' . $action->action] = array(
          '#type' => 'textfield',
          '#title' => st('Weight of %action action', array('%action' => $action->action)),
          '#default_value' => $action->weight,
      );
    }
  }
  $form['params']['qtr_decay'] = array(
      '#type' => 'select',
      '#title' => st('Time-decay of scores'),
      '#options' => array(0 => 'no decay', 1 => 'power-decay', 2 => 'exponential decay', 3 => 'theta-decay'),
      '#default_value' => variable_get('qtr_decay', 0),
  );
  
  $form['params']['qtr_tau0'] = array(
      '#type' => 'textfield',
      '#title' => st('Time scale of the decay (day)'),
      '#default_value' => variable_get('qtr_tau0', 50),
  );
  
  $form['params']['qtr_renorm_q'] = array(
      '#type' => 'textfield',
      '#title' => st('Renormalization of quality'),
      '#default_value' => variable_get('qtr_renorm_q', 0),
  );
  
  $form['params']['qtr_renorm_r'] = array(
      '#type' => 'textfield',
      '#title' => st('Renormalization of reputation'),
      '#default_value' => variable_get('qtr_renorm_r', 0),
  );
  
  $form['params']['qtr_renorm_t'] = array(
      '#type' => 'textfield',
      '#title' => st('Renormalization of trust'),
      '#default_value' => variable_get('qtr_renorm_t', 0),
  );
  
  $form['params']['qtr_resc_q'] = array(
      '#type' => 'textfield',
      '#title' => st('Rescaled quality'),
      '#default_value' => variable_get('qtr_resc_q', 0),
  );
  
  $form['params']['qtr_resc_r'] = array(
      '#type' => 'textfield',
      '#title' => st('Rescaled reputation'),
      '#default_value' => variable_get('qtr_resc_r', 0),
  );
  
  $form['params']['qtr_resc_t'] = array(
      '#type' => 'textfield',
      '#title' => st('Rescaled trust'),
      '#default_value' => variable_get('qtr_resc_t', 0),
  );
  
  $form['submit'] = array(
      '#type' => 'submit',
      '#value' => st('Save'),
  );
  return $form;
}

/**
 * Implements qscience_profile_qtr_settings_form_validate().
 * Checks that a successful response from the PDF Parser server is received.
 * 
 * @TO-DO: Ask for the ranges of the expected values
 */
function qscience_profile_qtr_settings_form_validate($form, &$form_state) {

}

/**
 * Implements qscience_profile_qtr_settings_form_submit().
 * Merges and executes the selected Patterns.
 */
function qscience_profile_qtr_settings_form_submit($form, &$form_state) {
  //Process the basic settings
  $result = array();
  $types = $form_state['values']['content_type'];
  foreach ($types as $type) {
    if ($type)
      $result[] = array('item_type' => $type);
  }
  qtr_update_itemtype($result);

  //Process the advanced settings
  $params = $form_state['values'];
  variable_set('qtr_delta', $params['qtr_delta']);
  variable_set('qtr_decay', $params['qtr_decay']);
  variable_set('qtr_tau0', $params['qtr_tau0']);
  variable_set('qtr_renorm_q', $params['qtr_renorm_q']);
  variable_set('qtr_renorm_r', $params['qtr_renorm_r']);
  variable_set('qtr_renorm_t', $params['qtr_renorm_t']);
  variable_set('qtr_resc_q', $params['qtr_resc_q']);
  variable_set('qtr_resc_r', $params['qtr_resc_t']);
  variable_set('qtr_resc_t', $params['qtr_resc_t']);
  $actions = qtr_get_actiontype();
  if ($actions) {
    foreach ($actions as $action) {
      qtr_update_actionweight($action->action, $params['qtr_w_' . $action->action]);
    }
  }
  drupal_set_message(st('QTR settings have been successfully saved.'));
}


/**
 * Implements qscience_profile_visualscience_settings_form().
 * 
 *  @TODO: Ask if we need to expand this form with fields from the rest of the related custom modules. 
 */
function qscience_profile_visualscience_settings_form($form, &$form_state, &$install_state) {
  drupal_set_title(st('Visual Science settings'));
  
  $form['livingscience_first_name'] = array(
      '#type' => 'textfield',
      '#default_value' => variable_get('livingscience_first_name', 'first_name'),
      '#title' => st('The name of the field to be used as the FIRST NAME of the author'),
     	'#autocomplete_path' => 'livingscience/fields/autocomplete',
      '#required' => FALSE,
  );
  
  $form['livingscience_last_name'] = array(
      '#type' => 'textfield',
      '#default_value' => variable_get('livingscience_last_name', 'last_name'),
      '#title' => st('The name of the field to be used as the LAST NAME of the author'),
     	'#autocomplete_path' => 'livingscience/fields/autocomplete',
      '#required' => FALSE,
  );
  
  $form['livingscience_full_name'] = array(
      '#type' => 'textfield',
      '#default_value' => variable_get('livingscience_full_name', ''),
      '#title' => st('The name of the field to be used as the FULL NAME of the author. If not empty, the first and last name fields will be ignored.'),
     	'#autocomplete_path' => 'livingscience/fields/autocomplete',
      '#required' => FALSE,
  );
  $form['submit'] = array(
      '#type' => 'submit',
      '#value' => st('Save'),
  );
  return $form;

}

/**
 * Implements qscience_profile_visualscience_settings_form_validate().
 * 
 * @TO-DO: Ask if some validation is required
 */
function qscience_profile_visualscience_settings_form_validate($form, &$form_state) {
  if (strlen(trim($form_state['values']['livingscience_first_name'])) == 0 &&
      strlen(trim($form_state['values']['livingscience_last_name'])) == 0 &&
      strlen(trim($form_state['values']['livingscience_full_name'])) == 0)
  {
    form_set_error('', st('Please fill in at least one of the fields.'));
  }
}

/**
 * Implements qscience_profile_pdfparser_settings_form_submit().
 */
function qscience_profile_visualscience_settings_form_submit($form, &$form_state) {
  variable_set('livingscience_first_name', $form_state['values']['livingscience_first_name']);
  variable_set('livingscience_last_name', $form_state['values']['livingscience_last_name']);
}

/**
 * Implements qscience_profile_d2d_settings_form().
 *
 *  @TODO: Ask if we need to simplify this form somehow.
 */
function qscience_profile_d2d_settings_form($form, &$form_state, &$install_state) {
  drupal_set_title(st('Drupal To Drupal settings'));
  
  $form = array();
  
  /*$form['introduction'] = array(
      '#markup' => t('Before using D2D, please provide a @length characters long D2D identifier. This identifier should be unique among all installations of D2D. It is recommended to generate that identifier randomly (e.g. by using the button below). If you installed D2D before, you can reuse the identifier of your old installation.', array('@length' => D2D_INSTANCE_IDENTIFIER_LENGTH)),
  );*/
  $form['name'] = array(
      '#type' => 'textfield',
      '#title' => t('Name'),
      '#description' => t('A short name describing your instance.'),
      '#default_value' => _d2d_suggest_instance_name($GLOBALS['base_url']),
      '#size' => D2D_INSTANCE_NAME_MAX_LENGTH,
      '#maxlength' => D2D_INSTANCE_NAME_MAX_LENGTH,
      '#required' => FALSE,
  );
  $form['id'] = array(
      '#type' => 'textfield',
      '#title' => t('D2D Identifier'),
      '#description' =>
      t(
          'A random Globally unique identifier has been automatically created. In case you need to modify it it should consist of exactly @length hexadecimal characters (A-F, 0-9).<br/>' .
          'Note: once you have saved the global identifier, it cannot be changed anymore.',
          array('@length' => D2D_INSTANCE_IDENTIFIER_LENGTH)
      ),
      '#default_value' => d2d_random_d2d_id(),
      '#size' => D2D_INSTANCE_IDENTIFIER_LENGTH,
      '#maxlength' => D2D_INSTANCE_IDENTIFIER_LENGTH,
      '#required' => TRUE,
  );
  $form['address'] = array(
      '#type' => 'textfield',
      '#title' => t('Address'),
      '#description' => t('The address under which this instance is reachable.'),
      '#default_value' => $GLOBALS['base_url'] . '/xmlrpc.php',
      '#size' => 40,
      '#maxlength' => D2D_INSTANCE_URL_MAX_LENGTH,
      '#required' => TRUE,
  );
  $form['auto_keys_and_online'] = array(
      '#type' => 'checkbox',
      '#default_value' => TRUE,
      '#title' => t('Automatically select public / private key pair and go online.'),
      '#description' => t('If selected, a random public / private key pair is automatically chosen and the instance will be marked as online, i.e. other instances will be able to see this instance and to communicate with this instance. Do not select this option if you want to manually set your public / private key pair, e.g. to reuse keys you have used with an old installation or if you do not want your instance to be online immediatelly.'),
  );
  $form['submit'] = array(
      '#type' => 'submit',
      '#value' => t('Save and continue'),
  );
  /*$form['generate'] = array(
      '#type' => 'submit',
      '#value' => t('Generate random identifier'),
      '#validate' => array('d2d_form_init_generate_validate'),
      '#submit' => array(),
  );*/
  return $form;
}

/**
 * Implements qscience_profile_d2d_settings_form_validate().
 *
 * @TO-DO: Ask if the validation should be simplified
 */
function qscience_profile_d2d_settings_form_validate($form, &$form_state) {
  $id = $form_state['values']['id'];
  if (!d2d_check_d2d_id_length($id)) {
    form_set_error('id', st('Identifier must constist of exactly @length characters.', array('@length' => D2D_INSTANCE_IDENTIFIER_LENGTH)));
  }
  if (!d2d_is_hex_string($id)) {
    form_set_error('id', st('Identifier must consists only of hexadecimal characters (A-F, 0-9).'));
  }
  if (!d2d_check_url($form_state['values']['address'])) {
    form_set_error('address', st('Address must start with \'http://\' or \'https://\'.'));
  }
}

/**
 * Implements qscience_profile_d2d_settings_form_submit().
 */
function qscience_profile_d2d_settings_form_submit($form, &$form_state) {
  if ($form_state['values']['auto_keys_and_online']) {
    if (!d2d_create_keys($my_public_key, $my_private_key)) {
      drupal_set_message(t('Failed creating public / private key pair.'), 'error');
      return;
    }
    variable_set('d2d_public_key', $my_public_key);
    variable_set('d2d_private_key', $my_private_key);
  }
  $my_d2d_id = $form_state['values']['id'];
  // add own instance to database
  $my_id = db_insert('d2d_instances')->fields(array(
      'name' => $form_state['values']['name'],
      'url' => $GLOBALS['base_url'] . '/xmlrpc.php',
      'd2d_id' => $my_d2d_id,
      'description' => 'this instance.',
      'time_inserted' => d2d_get_time(),
      'public_key_id' => NULL,
  ))->execute();
  variable_set('d2d_my_id', $my_id);
  if ($form_state['values']['auto_keys_and_online']) {
    $my_public_key_id = db_insert('d2d_public_keys')->fields(array(
        'instance_id' => $my_id,
        'public_key' => $my_public_key,
    ))->execute();
    $num_updated = db_update('d2d_instances')
    ->fields(array(
        'public_key_id' => $my_public_key_id,
    ))
    ->condition('id', $my_id)
    ->execute();
    variable_set('d2d_online', TRUE);
  }
  //menu_rebuild();
  //drupal_set_message(t('Settings have been saved.'));

}

/**
 * Implements qscience_profile_patterns_settings_form().
 */
function qscience_profile_patterns_settings_form($form, &$form_state, &$install_state) {
  // Set the install_profile variable employed by the function manually
  variable_set('install_profile', 'qscience_profile');
  $patterns = _patterns_io_get_patterns();
  // Set the status manually
  $patterns = $patterns[PATTERNS_STATUS_OK];
  // Display some example patterns to run
  $options = array();
  foreach($patterns as $pattern) {
    $options[$pattern->name] = $pattern->title .'<div class="description">'. $pattern->description .'</div>';
  }
  $form['patterns'] = array(
    '#type' => 'checkboxes',
    '#title' => st('Please select the Content Types you would like to install in your site'),
    '#description' => st('They will be set up via Patterns'),
    '#options' => $options,
  );
  $form['submit'] = array(
      '#type' => 'submit',
      '#value' => st('Continue'),
  );
  return $form;
}

/**
 * Implements qscience_profile_patterns_settings_form_submit().
 * Merges and executes the selected Patterns.
 */
function qscience_profile_patterns_settings_form_submit($form, &$form_state) {
  // Retrieve selected values and prepare execution
  $patterns_files = array_filter($form_state['values']['patterns']);
  if (count($patterns_files)>0) {
    // Retrieve the object of the first pattern file
    $pattern = _patterns_db_get_pattern(array_shift($patterns_files));
    // Merge actions of rest of patterns in the first one if any
    $pids = array();
    foreach($patterns_files as $pattern_file) {
      $subpattern = _patterns_db_get_pattern($pattern_file);
      foreach ($subpattern->pattern['actions'] as $action) {
        $pattern->pattern['actions'][] = $action;
      }
      $pids[] = $subpattern->pid;
    }
    // Execute merged pattern
    patterns_start_engine($pattern, array('run-subpatterns' => TRUE));
    // If all the subpatterns were successfully executed, marked the original ones as run
    foreach($pids as $pid) {
      $query_params = array(
        ':time' => time(),
        ':pid' => $pid,
        ':en' => PATTERNS_STATUS_ENABLED,
      );
      db_query("UPDATE {patterns} SET status = :en, enabled = :time WHERE pid = :pid", $query_params);
    }
  }
}