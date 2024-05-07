from flask import Flask, render_template, request
import pandas as pd
import plotly.express as px
import seaborn as sns
import numpy as np
import matplotlib.pyplot as plt
from sklearn.model_selection import train_test_split
from sklearn.discriminant_analysis import QuadraticDiscriminantAnalysis
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, confusion_matrix, precision_score, recall_score, f1_score, ConfusionMatrixDisplay
from flask import  jsonify
from flask_cors import CORS

from sklearn.preprocessing import StandardScaler
from collections import OrderedDict

app = Flask(__name__)
CORS(app)
# Load the data
data = pd.read_csv("app\static\water_potability_dataset.csv")
data = data.dropna()

# Prepare the data for dropdown options
dropdown_options = {
    'ph': 'PH',
    'Conductivity': 'Conductivity',
    'Turbidity': 'Turbidity',
    'Solids': 'Solids'
}

# Train the model
X = data.drop("Potability", axis=1)
y = data["Potability"]
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
qda_model = RandomForestClassifier(random_state=42)
qda_model.fit(X_train, y_train)


plt.figure(figsize=(15, 10))
sns.histplot(data['Potability'])
plt.title("Distribution of Unsafe and Safe Water")
prediction_label=None


@app.route('/', methods=['GET', 'POST'])
def index():
    potability_counts = data['Potability'].value_counts()
    fig = px.pie(names=potability_counts.index, values=potability_counts.values, title="Distribution of Unsafe and Safe Water")
    static_plot = fig.to_html(full_html=False)
    # Generate histogram for the selected feature
    selected_feature = request.form.get('feature', list(dropdown_options.keys())[0])
    fig = px.histogram(data, x=selected_feature, color='Potability', title=f"Distribution of {dropdown_options[selected_feature]}")
    histogram_plot = fig.to_html(full_html=False, default_height=500, default_width=700)

    # Make predictions on the testing set
    y_pred = qda_model.predict(X_test)

    # Calculate metrics
    accuracy = round(accuracy_score(y_test, y_pred)*100,3)
    precision = precision_score(y_test, y_pred)
    recall = recall_score(y_test, y_pred)
    f1 = f1_score(y_test, y_pred)
    conf_matrix = confusion_matrix(y_test, y_pred)
    
    colorscale =   [0.25, '#ffcc00'],  # Dark yellow
    [0.5, '#800080'],   # Purple
    [0.75, '#00cccc'],  # Cyan
    [1, '#008000']     # Green
    # Convert confusion matrix to HTML table
    conf_matrix_fig = px.imshow(conf_matrix, labels=dict(x="Predicted Label", y="True Label"),
                                     x=['False', 'True'], y=['False', 'True'],
                                 color_continuous_scale=colorscale)
    conf_matrix_plot = conf_matrix_fig.to_html(full_html=False)

    print(prediction_label)
    return render_template('index.html', static_plot=static_plot,dropdown_options=dropdown_options, histogram_plot=histogram_plot,
                           selected_feature=selected_feature, accuracy=accuracy, precision=precision, recall=recall, f1=f1, conf_matrix=conf_matrix_plot,prediction_label=prediction_label)





# Function to preprocess incoming data
def preprocess_data(data):
    # Create an ordered dictionary with constant values for features other than conductivity, pH, and turbidity
   
    column_order = ['ph', 'Turbidity', 'Solids', 'Conductivity']
    # Combine constant values with incoming data
    
    
    # Convert combined data to DataFrame
    df = pd.DataFrame(data,columns=column_order, index=[0])
    df.fillna(method='ffill', inplace=True)
    
    return df

# Flask route to accept new data from Flutter app
@app.route('/predict', methods=['POST'])
def predict():
    # Get the JSON data sent from the Flutter app
    request_data = request.json
  
    # Preprocess the incoming data
    input_data = preprocess_data(request_data)
    print(input_data)
    
    # Make predictions
    prediction = qda_model.predict(input_data)
    print(prediction)
    # Convert prediction to a human-readable format (if needed)
    global prediction_label
    prediction_label = "Potable" if prediction[0] == 1 else "Not Potable"
    
    # Return the prediction as JSON
    return jsonify({"prediction": prediction_label})
    

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
