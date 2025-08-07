def time_weighted_error(y_true, y_pred, alpha=0.02, beta=1):
  """Returns the weighted squared error for an array of predictions."""

  error = y_pred-y_true

  weight = np.where(
  error >= 0,
  2 / (1 + alpha * y_true),
  1 / (1 + alpha * y_true)
  )
  return weight * (error ** 2)*beta

def score_submitted_result(df_true, df_pred):
  '''Calculate the score for a single team's submission'''

  # Extract the targets
  true_WW = df_true.Cycles_to_WW.values
  true_HPC = df_true.Cycles_to_HPC_SV.values
  true_HPT = df_true.Cycles_to_HPT_SV.values

  pred_WW = df_pred.Cycles_to_WW.values
  pred_HPC = df_pred.Cycles_to_HPC_SV.values
  pred_HPT = df_pred.Cycles_to_HPT_SV.values

  # WW score
  alpha = 0.01
  beta = 1/float(max(true_WW))
  score_WW = time_weighted_error(true_WW, pred_WW, alpha, beta)
  # Take the mean of the array
  score_WW = np.mean(score_WW)

  # HPC score
  alpha = 0.01
  beta = 2/float(max(true_HPC))
  score_HPC = time_weighted_error(true_HPC, pred_HPC, alpha, beta)
  # Take the mean of the array
  score_HPC = np.mean(score_HPC)

  # HTC score
  alpha = 0.01
  beta = 2/float(max(true_HPT))
  score_HPT = time_weighted_error(true_HPT, pred_HPT, alpha, beta)
  # Take the mean of the array
  score_HPT = np.mean(score_HPT)

  # Average score
  score = np.mean([score_WW, score_HPC, score_HPT])

  return score