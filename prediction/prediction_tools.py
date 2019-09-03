import matplotlib.pyplot as plt
import numpy as np

from sklearn.metrics import auc, average_precision_score, confusion_matrix, \
    precision_recall_curve, precision_recall_fscore_support, roc_curve

def error_analysis(X, y, y_pred, export=False):
    print "\nFalse Positives"
    indices = np.argsort(y_pred - y)[-5:]
    false_positives = X.iloc[indices]
    false_positives['probability'] = y_pred[indices]
    display(false_positives)

    print "\nFalse Negatives"
    indices = np.argsort(y - y_pred)[-5:]
    false_negatives = X.iloc[indices]
    false_negatives['probability'] = y_pred[indices]
    display(false_negatives)

    if export:
        export_table = false_positives.append(false_negatives)
        export_table.to_csv('./error_analysis/error_analysis_selected.csv')

# Adapted from https://stackoverflow.com/a/47679281
def get_youden_threshold(true_labels, scores):
    fpr, tpr, threshold = roc_curve(true_labels, scores)
    j_scores = np.array(tpr) - np.array(fpr)
    j_ordered = sorted(zip(j_scores, threshold))
    return j_ordered[-1][1]

# https://scikit-learn.org/stable/auto_examples/model_selection/plot_confusion_matrix.html
def plot_confusion_matrix(y_true, y_pred):
    cm = confusion_matrix(y_true, y_pred)

    fig, ax = plt.subplots()
    im = ax.imshow(cm, interpolation='nearest', cmap=plt.cm.Blues)
    # We want to show all ticks...
    ax.set(xticks=np.arange(cm.shape[1]),
           yticks=np.arange(cm.shape[0]),
           # ... and label them with the respective list entries
           title='Confusion Matrix',
           ylabel='True label',
           xlabel='Predicted label')

    # Loop over data dimensions and create text annotations.
    thresh = cm.max() / 2.
    for i in range(cm.shape[0]):
        for j in range(cm.shape[1]):
            ax.text(j, i, format(cm[i, j], 'd'),
                    ha="center", va="center",
                    color="white" if cm[i, j] > thresh else "black")
    plt.show()

def plot_prc(true_labels, scores):
    average_precision = average_precision_score(true_labels, scores)
    precision, recall, _ = precision_recall_curve(true_labels, scores)
    label = 'AUC = %0.2f' % auc(recall, precision)
    plt.plot(recall, precision, label=label, marker='.', markersize=1)
    plt.title("Precision-Recall Curve: AP={0:0.2f}".format(average_precision))
    plt.legend(loc = 'upper right')
    plt.xlabel("Recall")
    plt.ylabel("Precision")
    plt.xlim([0.0, 1.0])
    plt.ylim([0.0, 1.0])
    plt.show()

# Adapted from https://stackoverflow.com/a/38467407
def plot_roc(true_labels, scores, title):
    fpr, tpr, threshold = roc_curve(true_labels, scores)
    label = 'AUC = %0.2f' % auc(fpr, tpr)
    plt.plot(fpr, tpr, 'b', label=label)
    plt.plot([0, 1], [0, 1], 'r--')
    plt.title(title)
    plt.legend(loc = 'lower right')
    plt.xlabel("False Positive Rate")
    plt.ylabel("True Positive Rate")
    plt.xlim([0, 1])
    plt.ylim([0, 1])
    plt.show()

# For logistic regression classifiers
def print_feature_weights(feature_weights):
    print "Coefficients:"
    for feature, weight in sorted(feature_weights, key=lambda x: x[1], reverse=True):
        print "%25s: %7.4f" % (feature, weight)

def print_metrics(y_true, y_pred):
    plot_confusion_matrix(y_true, y_pred)
    precision, recall, f1_score, _ = precision_recall_fscore_support(y_true, y_pred)
    print "Precision: ", precision[1]
    print "Recall   : ", recall[1]
    print "F-measure: ", f1_score[1]

def print_params(clf, params):
    print "Selected parameters:"
    for param in params:
        print "- %s: %s" % (param, clf.best_estimator_.get_params()[param])
