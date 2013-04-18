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

  // Add a page to allow running some patterns
  $tasks['qscience_profile_pdfparser_settings_form'] = array(
      'display_name' => st('Configure PDF Parser'),
      'type' => 'form',
  );
  
  // Add a page to allow running some patterns
  $tasks['qscience_profile_qtr_settings_form'] = array(
      'display_name' => st('Configure QTR'),
      'type' => 'form',
  );  
  
  // Add a page to allow running some patterns
  $tasks['qscience_profile_patterns_settings_form'] = array(
      'display_name' => st('Choose Content Types'),
      'type' => 'form',
  );
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
 * Implements qscience_profile_pdfparser_settings_form().
 */
function qscience_profile_pdfparser_settings_form($form, &$form_state, &$install_state) {
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