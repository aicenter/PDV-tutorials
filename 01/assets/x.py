import numpy as np
import matplotlib.pyplot as plt
from datetime import datetime, timedelta

# Generate Fibonacci numbers
def fibonacci(n):
    fib = [1, 1]
    for i in range(2, n):
        fib.append(fib[i-1] + fib[i-2])
    return fib

# Generate random walk data that looks like stock prices
np.random.seed(42)
n_points = 100
base_price = 100
volatility = 0.02
price = base_price * (1 + np.random.randn(n_points).cumsum() * volatility)

# Create date range
dates = [datetime.now() + timedelta(days=x) for x in range(n_points)]

# Calculate EMAs for different Fibonacci periods
def calculate_ema(data, period):
    alpha = 2 / (period + 1)
    result = [data[0]]
    for n in range(1, len(data)):
        ema = data[n] * alpha + result[n-1] * (1 - alpha)
        result.append(ema)
    return result

# Get Fibonacci numbers for periods
fib_periods = [8, 13, 21]  # Common Fibonacci numbers used in trading
emas = {period: calculate_ema(price, period) for period in fib_periods}

# Create the plot
plt.figure(figsize=(10, 6))
plt.plot(dates, price, label='Price', color='#2E86C1', alpha=0.6)

colors = ['#E74C3C', '#2ECC71', '#F39C12']
for (period, ema), color in zip(emas.items(), colors):
    plt.plot(dates, ema, label=f'Fib EMA ({period})', color=color, linewidth=2)

# Customize the plot
plt.title('Price with Fibonacci EMAs')
plt.xlabel('Date')
plt.ylabel('Price')
plt.grid(True, linestyle='--', alpha=0.7)
plt.legend()

# Rotate date labels
plt.xticks(rotation=45)

# Adjust layout
plt.tight_layout()

# Save as SVG
plt.savefig('ema.svg', format='svg', bbox_inches='tight')